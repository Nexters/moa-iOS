//
//  WorkViewController.swift
//  Moa
//

import UIKit
import Combine
import SnapKit
import UserNotifications

// MARK: - CoordinatorDelegate

protocol WorkViewControllerCoordinatorDelegate: AnyObject {
    func workViewControllerDidTapCalendar(_ viewController: WorkViewController)
    func workViewControllerDidTapSetting(_ viewController: WorkViewController)
    func workViewControllerDidTapWorkComplete(_ viewController: WorkViewController)
    /// 일정 조정 / idle 근무시간 수정 → FixScheduleViewController push
    func workViewControllerDidTapChangeSchedule(
        _ viewController: WorkViewController,
        workday: CalendarScheduleEntity,
        joinedAt: Date?
    )
}

// MARK: - WorkViewController

final class WorkViewController: BaseViewController {
    
    private enum Constant {
        static let navigationBarHeight: CGFloat = 44
    }
    
    // MARK: - Properties
    
    private let viewModel: WorkViewModel
    private var workingTimer: Timer?
    private var workingScreenEntryTime: Date?
    
    override var prefersNavigationBarHidden: Bool { true }
    weak var coordinatorDelegate: WorkViewControllerCoordinatorDelegate?
    
    // MARK: - UI
    
    private let navigationBarView = HomeNavigationBarView()
    
    private lazy var workMainView: WorkMainContentView = {
        let view = WorkMainContentView()
        view.delegate = self
        return view
    }()
    
    private lazy var workingContentView: WorkingContentView = {
        let view = WorkingContentView(workingType: .work)
        view.delegate = self
        return view
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Init
    
    init(viewModel: WorkViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.send(.viewDidLoad)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.trackNotificationPermission()
        viewModel.send(.refresh)
        
        if case let .loaded(status, _) = viewModel.state,
           status == .working || status == .workFinished {
            startWorkingTimer()
        }
        if case let .loaded(status, _) = viewModel.state, status == .working {
            recordWorkingScreenEntry()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showWorkAlarmBottomSheetIfNeeded()
        presentSalaryOverlayIfNeededIfPossible()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopWorkingTimer()
        sendWorkingScreenTimeIfNeeded()
    }
    
    // MARK: - Setup
    
    override func setupUI() {
        view.backgroundColor = AppColor.Background.primary
        setupHierarchy()
        setupConstraints()
        
        navigationBarView.onCalendarTap = { [weak self] in
            guard let self else { return }
            coordinatorDelegate?.workViewControllerDidTapCalendar(self)
        }
        navigationBarView.onTapSetting = { [weak self] in
            guard let self else { return }
            coordinatorDelegate?.workViewControllerDidTapSetting(self)
        }
    }
    
    override func bind() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.render($0) }
            .store(in: &cancellables)
        
        viewModel.$state
            .map { state -> Bool in
                if case .loading = state { return true }
                return false
            }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { isLoading in
                isLoading ? LoadingManager.shared.show() : LoadingManager.shared.hide()
            }
            .store(in: &cancellables)
    }
}

// MARK: - Layout

private extension WorkViewController {
    
    func setupHierarchy() {
        view.addSubViews([
            navigationBarView,
            workMainView,
            workingContentView,
            loadingIndicator
        ])
    }
    
    func setupConstraints() {
        navigationBarView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(Constant.navigationBarHeight)
        }
        
        workMainView.snp.makeConstraints {
            $0.top.equalTo(navigationBarView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        workingContentView.snp.makeConstraints {
            $0.top.equalTo(navigationBarView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        loadingIndicator.snp.makeConstraints { $0.center.equalToSuperview() }
    }
}

// MARK: - Render

private extension WorkViewController {
    
    func render(_ state: WorkViewState) {
        switch state {
        case .idle:
            break
        case .loading:
            renderLoading()
        case let .loaded(status, data):
            renderLoaded(status: status, data: data)
        case let .error(error):
            renderError(error)
        }
    }
    
    func renderLoading() {
        loadingIndicator.startAnimating()
        workMainView.isHidden       = true
        workingContentView.isHidden = true
    }
    
    func renderLoaded(status: WorkStatusEntity, data: HomeEntity) {
        loadingIndicator.stopAnimating()
        
        switch status {
        case .idle:
            renderIdleView(data: data)
        case .working:
            renderActiveWork(status: status, data: data)
        case .workFinished:
            renderActiveWork(status: status, data: data)
        case .finished:
            renderFinalComplete(data: data)
        }
    }
    
    func renderIdleView(data: HomeEntity) {
        stopWorkingTimer()
        sendWorkingScreenTimeIfNeeded()
        workingContentView.stopAnimations()
        workMainView.isHidden       = false
        workingContentView.isHidden = true
        workMainView.configure(data: data, status: .idle)
    }
    
    func renderActiveWork(status: WorkStatusEntity, data: HomeEntity) {
        workMainView.isHidden       = true
        workingContentView.isHidden = false
        
        let workingType: WorkingType = (data.type == .vacation) ? .vacation : .work
        let startTime = data.clockInTime  ?? TimeIndicatorEntity(hour: 9,  minute: 0)
        let endTime   = data.clockOutTime ?? TimeIndicatorEntity(hour: 18, minute: 0)
        let startedAt = makeDate(hour: startTime.hour, minute: startTime.minute)
        
        workingContentView.configure(
            dailyPay:    data.dailyPay,
            startTime:   startTime,
            endTime:     endTime,
            startedAt:   startedAt,
            workingType: workingType,
            status:      status,
            data:        data
        )
        
        if status == .working {
            workingContentView.startAnimations()
            recordWorkingScreenEntry()
        }
        
        startWorkingTimer()
    }
    
    func renderFinalComplete(data: HomeEntity) {
        stopWorkingTimer()
        sendWorkingScreenTimeIfNeeded()
        workingContentView.stopAnimations()
        workMainView.isHidden       = false
        workingContentView.isHidden = true
        workMainView.configure(data: data, status: .finished)
    }
    
    func renderError(_ error: WorkViewError) {
        loadingIndicator.stopAnimating()
        showErrorAlert(message: error.localizedDescription)
    }
}

// MARK: - Timer

private extension WorkViewController {
    
    func startWorkingTimer() {
        stopWorkingTimer()
        workingTimer = Timer(timeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.workingContentView.tick()
            self.checkAutoWorkFinish()
        }
        RunLoop.main.add(workingTimer!, forMode: .common)
    }
    
    func stopWorkingTimer() {
        workingTimer?.invalidate()
        workingTimer = nil
    }
    
    func checkAutoWorkFinish() {
        guard case let .loaded(status, data) = viewModel.state,
              status == .working,
              let clockOut = data.clockOutTime else { return }
        
        let now = Calendar.korea.dateComponents([.hour, .minute], from: Date())
        let nowMinutes = (now.hour ?? 0) * 60 + (now.minute ?? 0)
        
        guard nowMinutes >= clockOut.totalMinutes else { return }
        viewModel.send(.endWork)
    }
}

// MARK: - Navigation to FixScheduleViewController

private extension WorkViewController {
    
    /// 현재 HomeEntity를 오늘 날짜 기준 CalendarScheduleEntity로 변환
    func makeScheduleEntity(from data: HomeEntity) -> CalendarScheduleEntity {
        CalendarScheduleEntity(
            date:           Calendar.korea.startOfDay(for: Date()),
            contentType:    data.type,
            status:         .scheduled,
            events:         [],
            dailyPay:       data.dailyPay,
            clockInTime:    data.clockInTime,
            clockOutTime:   data.clockOutTime,
            isToday:        true,
            isSelected:     false,
            isCurrentMonth: true
        )
    }
    
    /// FixScheduleViewController push — 날짜 변경 불가(오늘 고정)
    func pushFixSchedule(from data: HomeEntity) {
        let workday = makeScheduleEntity(from: data)
        coordinatorDelegate?.workViewControllerDidTapChangeSchedule(
            self,
            workday:  workday,
            joinedAt: nil   // Coordinator가 캐싱한 joinedAt 사용
        )
    }
}

// MARK: - Bottom Sheet Presentation

private extension WorkViewController {
    
    private func showWorkAlarmBottomSheetIfNeeded() {
        NotificationManager.shared.checkAuthorizationStatus { [weak self] status in
            guard let self else { return }
            switch status {
            case .notDetermined, .denied:
                if !UserDefaults.standard.bool(forKey: "HasShownWorkAlarmSheet") {
                    UserDefaults.standard.set(true, forKey: "HasShownWorkAlarmSheet")
                    self.showWorkAlarmBottomSheet()
                }
            case .authorized, .provisional, .ephemeral:
                break
            @unknown default:
                break
            }
        }
    }
    
    func showWorkAlarmBottomSheet() {
        let vc = WorkAlarmBottomSheet()
        vc.delegate = self
        presentBottomSheet(vc)
    }
    
    func presentExtendTimeBottomSheet() {
        guard case let .loaded(_, data) = viewModel.state else { return }
        let startTime = data.clockInTime  ?? TimeIndicatorEntity(hour: 9,  minute: 0)
        let endTime   = data.clockOutTime ?? TimeIndicatorEntity(hour: 18, minute: 0)
        presentTimeSheet(type: .extendEndTime, startTime: startTime, endTime: endTime)
    }
    
    func presentFinishedTimeEditBottomSheet() {
        guard case let .loaded(_, data) = viewModel.state else { return }
        self.pushFixSchedule(from: data)
    }
    
    private func presentTimeSheet(
        type:      TimeSelectionBottomSheetCase,
        startTime: TimeIndicatorEntity,
        endTime:   TimeIndicatorEntity
    ) {
        let present = { [weak self] in
            guard let self else { return }
            let sheet = TimeSelectionBottomSheet(type: type, startTime: startTime, endTime: endTime)
            sheet.delegate = self
            self.presentBottomSheet(sheet)
        }
        if presentedViewController != nil {
            dismiss(animated: true, completion: present)
        } else {
            present()
        }
    }
    
    func presentScheduleChangeBottomSheet() {
        guard presentedViewController == nil else { return }
        let sheet = WorkScheduleChangeBottomSheet()
        sheet.delegate = self
        presentBottomSheet(sheet)
    }
}

// MARK: - Alert

private extension WorkViewController {
    
    func showErrorAlert(message: String) {
        let vc = MoaAlertViewController(message: message)
        present(vc, animated: true)
    }
}

// MARK: - Analytics

private extension WorkViewController {
    
    func recordWorkingScreenEntry() {
        guard workingScreenEntryTime == nil else { return }
        workingScreenEntryTime = Date()
    }
    
    func sendWorkingScreenTimeIfNeeded() {
        guard let entryTime = workingScreenEntryTime else { return }
        let seconds = Int(Date().timeIntervalSince(entryTime))
        Analytics.track(.workingScreenTime(seconds: seconds))
        workingScreenEntryTime = nil
    }
}

// MARK: - Helpers

private extension WorkViewController {
    
    func makeDate(hour: Int, minute: Int) -> Date {
        var c = Calendar.korea.dateComponents([.year, .month, .day], from: Date())
        c.hour = hour; c.minute = minute; c.second = 0
        return Calendar.korea.date(from: c) ?? Date()
    }
}

// MARK: - WorkAlarmBottomSheetDelegate

extension WorkViewController: WorkAlarmBottomSheetDelegate {
    func didTapAlarm() { requestNotificationPermission() }
    func didTapLater()  {}
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in
            DispatchQueue.main.async {
                if granted { print("알림 권한 승인됨") }
                else if let e = error { print("알림 오류: \(e.localizedDescription)") }
            }
        }
    }
}

// MARK: - TimeSelectionBottomSheetDelegate
// workFinished 상태에서 완료 후 실제 근무 시간 수정 시에만 사용

extension WorkViewController: TimeSelectionBottomSheetDelegate {
    
    func timeSelectionBottomSheet(
        _ sheet: TimeSelectionBottomSheet,
        didConfirmStartTime startTime: TimeIndicatorEntity,
        endTime: TimeIndicatorEntity
    ) {
        guard case let .loaded(status, _) = viewModel.state else { return }
        switch status {
        case .workFinished:
            viewModel.send(.editFinishedWorkTime(start: startTime, end: endTime))
        default:
            viewModel.send(.updateWorkTime(start: startTime, end: endTime))
        }
    }
    
    func timeSelectionBottomSheetDidTapOption(_ sheet: TimeSelectionBottomSheet) {
        viewModel.send(.requestVacation)
    }
}

// MARK: - WorkMainContentViewDelegate

extension WorkViewController: WorkMainContentViewDelegate {
    
    func workMainContentViewDidTapPrimaryAction(_ view: WorkMainContentView) {
        guard case let .loaded(_, data) = viewModel.state else { return }
        if data.type == .work {
            Analytics.track(.beforeWorkNowWorkClicked)
            viewModel.send(.startWork)
        } else {
            coordinatorDelegate?.workViewControllerDidTapCalendar(self)
        }
    }
    
    func workMainContentViewDidTapVacation(_ view: WorkMainContentView) {
        viewModel.send(.requestVacation)
    }
    
    /// idle 상태에서 근무 시간 탭 → 바텀시트 대신 FixScheduleViewController push
    func workMainContentViewDidRequestTimeSelection(_ view: WorkMainContentView) {
        guard case let .loaded(_, data) = viewModel.state else { return }
        Analytics.track(.beforeWorkWorkTimeClicked)
        pushFixSchedule(from: data)
    }
    
    func workMainContentViewDidTapWorkHistory(_ view: WorkMainContentView) {
        coordinatorDelegate?.workViewControllerDidTapCalendar(self)
    }
}

// MARK: - WorkingContentViewDelegate

extension WorkViewController: WorkingContentViewDelegate {
    
    /// 근무 중 "일정 조정" 탭
    /// - vacation 타입: 바텀시트 없이 바로 FixScheduleViewController push
    /// - work 타입:     기존대로 WorkScheduleChangeBottomSheet 표시
    func workingContentViewDidTapScheduleAdjust(_ view: WorkingContentView) {
        guard case let .loaded(_, data) = viewModel.state else { return }
        
        if data.type == .vacation {
            // 휴가 중 일정 조정 — 바텀시트 없이 직접 FixSchedule push
            pushFixSchedule(from: data)
        } else {
            // 일반 근무 중 일정 조정 — 종료 / 조정 선택 바텀시트
            presentScheduleChangeBottomSheet()
        }
    }
    
    func workingContentViewDidTapExtendWork(_ view: WorkingContentView) {
        Analytics.track(.workingMoreWorkClicked)
        presentExtendTimeBottomSheet()
    }
    
    func workingContentViewDidTapTimeRow(_ view: WorkingContentView) {
        Analytics.track(.workingWorkTimeClicked)
        presentFinishedTimeEditBottomSheet()
    }
    
    func workingContentViewDidTapConfirm(_ view: WorkingContentView) {
        Analytics.track(.workingWorkCompletedClicked)
        viewModel.send(.confirmWork)
        coordinatorDelegate?.workViewControllerDidTapWorkComplete(self)
    }
}

// MARK: - WorkScheduleChangeBottomSheetDelegate
// work 타입 근무 중 일정 조정 시에만 진입

extension WorkViewController: WorkScheduleChangeBottomSheetDelegate {
    
    func workScheduleChangeBottomSheet(
        _ sheet: WorkScheduleChangeBottomSheet,
        didConfirm type: WorkScheduleChangeType
    ) {
        switch type {
        case .endWork:
            dismiss(animated: true) { [weak self] in
                self?.viewModel.send(.endWork)
            }
            
        case .changeSchedule:
            dismiss(animated: true) { [weak self] in
                guard let self,
                      case let .loaded(_, data) = self.viewModel.state
                else { return }
                self.pushFixSchedule(from: data)
            }
        }
    }
    
    func workScheduleChangeBottomSheetDidCancel(_ sheet: WorkScheduleChangeBottomSheet) {
        dismiss(animated: true)
    }
}

private extension WorkViewController {
    
    func presentSalaryOverlayIfNeededIfPossible() {
        
        guard presentedViewController == nil else {
            return
        }
        
        guard case let .loaded(_, data) = viewModel.state else {
            return
        }
        
        // payday 이벤트가 없는 날이면 노출하지 않음
        guard data.events.contains(.payday) else { return }
        
        // 이번 달에 이미 표시한 적이 있으면 노출하지 않음
        guard SalaryOverlayView.shouldPresentThisMonth() else { return }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        // dailyPay(일급) 대신 standardSalary(월급) 사용
        let salaryString = formatter.string(from: NSNumber(value: data.standardSalary)) ?? "0"
        
        let overlay = SalaryOverlayView(
            salaryText: salaryString
        )
        
        overlay.alpha = 0
        
        view.addSubview(overlay)
        
        overlay.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        view.bringSubviewToFront(overlay)
        
        UIView.animate(withDuration: 0.25) {
            overlay.alpha = 1
        }
        
        SalaryOverlayView.markPresented()
    }
}
