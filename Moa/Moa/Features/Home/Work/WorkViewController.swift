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
    /// 근무완료 1에서 "완료" 탭 → 최종 완료 페이지
    func workViewControllerDidTapWorkComplete(_ viewController: WorkViewController)
}

// MARK: - WorkViewController

final class WorkViewController: BaseViewController {

    private enum Constant {
        static let navigationBarHeight: CGFloat = 44
    }

    // MARK: - Properties

    private let viewModel: WorkViewModel
    private var workingTimer: Timer?

    override var prefersNavigationBarHidden: Bool { true }
    weak var coordinatorDelegate: WorkViewControllerCoordinatorDelegate?

    // MARK: - UI

    private let navigationBarView = HomeNavigationBarView()

    /// idle / 최종완료(finished) 상태 화면
    private lazy var workMainView: WorkMainContentView = {
        let view = WorkMainContentView()
        view.delegate = self
        return view
    }()

    /// working / 근무완료1(finished+오버레이) 상태 화면
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

    // MARK: - State

    /// "완료" 탭 후 최종완료 페이지 여부
    private var hasConfirmedWork = false

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
        if case let .loaded(status, _) = viewModel.state,
           status == .working || status == .finished {
            startWorkingTimer()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showWorkAlarmBottomSheetIfNeeded()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopWorkingTimer()
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
    }
}

// MARK: - Layout

private extension WorkViewController {

    func setupHierarchy() {
        view.addSubViews([navigationBarView, workMainView, workingContentView, loadingIndicator])
    }

    func setupConstraints() {
        navigationBarView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(Constant.navigationBarHeight)
        }
        [workMainView, workingContentView].forEach {
            $0.snp.makeConstraints {
                $0.top.equalTo(navigationBarView.snp.bottom)
                $0.leading.trailing.bottom.equalToSuperview()
            }
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

    func renderLoaded(status: WorkStatus, data: HomeEntity) {
        loadingIndicator.stopAnimating()
        switch status {
        case .idle:
            hasConfirmedWork = false
            renderIdleView(data: data)
        case .working:
            hasConfirmedWork = false
            renderActiveWork(status: status, data: data)
        case .finished:
            if hasConfirmedWork {
                // 최종 완료 페이지 (WorkMainContentView, status: .finished)
                renderFinalComplete(data: data)
            } else {
                // 근무완료 1 — WorkingContentView + WorkEndBottomIndicator 오버레이
                renderActiveWork(status: status, data: data)
            }
        }
    }

    func renderIdleView(data: HomeEntity) {
        stopWorkingTimer()
        workingContentView.stopAnimations()
        workMainView.isHidden       = false
        workingContentView.isHidden = true
        workMainView.configure(data: data, status: .idle)
    }

    func renderActiveWork(status: WorkStatus, data: HomeEntity) {
        workMainView.isHidden       = true
        workingContentView.isHidden = false

        let workingType: WorkingType = data.type == .vacation ? .vacation : .work
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
        startWorkingTimer()
    }

    /// 최종 완료 페이지 — WorkMainContentView (status: .finished)
    /// - MonthlySalaryView: imgFullMoney, 금액 녹색
    /// - WorkMainSummaryView: dailyPay, 탭 불가, 휴가 시 "휴가"
    /// - 하단 버튼: "이번달 근무 기록 확인하기"
    func renderFinalComplete(data: HomeEntity) {
        stopWorkingTimer()
        workingContentView.stopAnimations()
        workMainView.isHidden       = false
        workingContentView.isHidden = true
        workMainView.configure(data: data, status: .finished)
    }

    func renderError(_ error: WorkViewError) {
        loadingIndicator.stopAnimating()
        showErrorAlert(message: error.localizedDescription ?? "")
    }
}

// MARK: - Timer

private extension WorkViewController {

    func startWorkingTimer() {
        stopWorkingTimer()
        workingTimer = Timer(timeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.workingContentView.tick()
        }
        RunLoop.main.add(workingTimer!, forMode: .common)
    }

    func stopWorkingTimer() {
        workingTimer?.invalidate()
        workingTimer = nil
    }
}

// MARK: - Bottom Sheet Presentation

private extension WorkViewController {

    private func showWorkAlarmBottomSheetIfNeeded() {

        NotificationManager.shared.checkAuthorizationStatus { [weak self] status in
            guard let self else { return }

            switch status {

            case .notDetermined, .denied:
                // 최초 진입 → 바텀시트 노출
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

    /// idle: 출퇴근 시간 설정 (.setEstimateTime: "예상 출퇴근 시간을 알려주세요")
    func presentTimeSelectionBottomSheet() {
        guard case let .loaded(_, data) = viewModel.state else { return }
        let startTime = data.clockInTime  ?? TimeIndicatorEntity(hour: 9,  minute: 0)
        let endTime   = data.clockOutTime ?? TimeIndicatorEntity(hour: 18, minute: 0)
        presentTimeSheet(type: .setEstimateTime, startTime: startTime, endTime: endTime)
    }

    /// 근무완료 1 → "더 일할게요": 퇴근 시간 연장 (.extendEndTime)
    func presentExtendTimeBottomSheet() {
        guard case let .loaded(_, data) = viewModel.state else { return }
        let startTime = data.clockInTime  ?? TimeIndicatorEntity(hour: 9,  minute: 0)
        let endTime   = data.clockOutTime ?? TimeIndicatorEntity(hour: 18, minute: 0)
        presentTimeSheet(type: .extendEndTime, startTime: startTime, endTime: endTime)
    }

    /// 근무완료 1 → 근무시간 탭: 출퇴근 수정 (.changeWorkTime)
    func presentFinishedTimeEditBottomSheet() {
        guard case let .loaded(_, data) = viewModel.state else { return }
        let startTime = data.clockInTime  ?? TimeIndicatorEntity(hour: 9,  minute: 0)
        let endTime   = data.clockOutTime ?? TimeIndicatorEntity(hour: 18, minute: 0)
        presentTimeSheet(type: .changeWorkTime, startTime: startTime, endTime: endTime)
    }

    /// 근무 중 "근무 일정에 변동이 있어요" → 예상 출퇴근 시간 변경
    /// (.setEstimateTime: "예상 출퇴근 시간을 알려주세요" + [확인] 버튼)
    func presentWorkingScheduleAdjustBottomSheet() {
        guard case let .loaded(_, data) = viewModel.state else { return }
        let startTime = data.clockInTime  ?? TimeIndicatorEntity(hour: 9,  minute: 0)
        let endTime   = data.clockOutTime ?? TimeIndicatorEntity(hour: 18, minute: 0)
        presentTimeSheet(type: .setEstimateTime, startTime: startTime, endTime: endTime)
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
        let alert = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }

    func showVacationConfirmAlert() {
        let alert = UIAlertController(
            title: "휴가 신청",
            message: "오늘 휴가를 신청하시겠어요?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "신청", style: .default) { [weak self] _ in
            self?.viewModel.send(.requestVacation)
        })
        present(alert, animated: true)
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
    func didTapLater() {}

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

extension WorkViewController: TimeSelectionBottomSheetDelegate {

    func timeSelectionBottomSheet(
        _ sheet: TimeSelectionBottomSheet,
        didConfirmStartTime startTime: TimeIndicatorEntity,
        endTime: TimeIndicatorEntity
    ) {
        guard case let .loaded(status, _) = viewModel.state else { return }
        if status == .finished {
            // 근무완료 1: 출퇴근 수정 → finished 유지
            viewModel.send(.updateWorkTime(start: startTime, end: endTime))
        } else {
            // idle: setEstimateTime 확인
            // working: setEstimateTime(.changeSchedule) 또는 extendEndTime
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
        viewModel.send(.startWork)
    }

    func workMainContentViewDidTapVacation(_ view: WorkMainContentView) {
        viewModel.send(.requestVacation)
    }

    func workMainContentViewDidRequestTimeSelection(_ view: WorkMainContentView) {
        presentTimeSelectionBottomSheet()
    }

    /// 최종완료: "이번달 근무 기록 확인하기" → 캘린더(History) 화면
    func workMainContentViewDidTapWorkHistory(_ view: WorkMainContentView) {
        coordinatorDelegate?.workViewControllerDidTapCalendar(self)
    }
}

// MARK: - WorkingContentViewDelegate

extension WorkViewController: WorkingContentViewDelegate {

    /// working: "일정 조정" 탭 → WorkScheduleChangeBottomSheet
    func workingContentViewDidTapScheduleAdjust(_ view: WorkingContentView) {
        presentScheduleChangeBottomSheet()
    }

    /// 근무완료 1: "더 일할게요" → extendEndTime 시트
    func workingContentViewDidTapExtendWork(_ view: WorkingContentView) {
        presentExtendTimeBottomSheet()
    }

    /// 근무완료 1: 근무시간 탭 → changeWorkTime 시트
    func workingContentViewDidTapTimeRow(_ view: WorkingContentView) {
        presentFinishedTimeEditBottomSheet()
    }

    /// 근무완료 1: "완료" → 최종 완료 페이지
    func workingContentViewDidTapConfirm(_ view: WorkingContentView) {
        hasConfirmedWork = true
        guard case let .loaded(_, data) = viewModel.state else { return }
        renderFinalComplete(data: data)
        coordinatorDelegate?.workViewControllerDidTapWorkComplete(self)
    }
}

// MARK: - WorkScheduleChangeBottomSheetDelegate

extension WorkViewController: WorkScheduleChangeBottomSheetDelegate {

    func workScheduleChangeBottomSheet(
        _ sheet: WorkScheduleChangeBottomSheet,
        didConfirm type: WorkScheduleChangeType
    ) {
        switch type {
        case .vacation:
            dismiss(animated: true) { [weak self] in self?.viewModel.send(.requestVacation) }

        case .endWork:
            // 오늘 근무를 마칠게요 → updateWorkday API (타입+시작+끝)
            dismiss(animated: true) { [weak self] in self?.viewModel.send(.endWork) }

        case .changeSchedule:
            // 근무 일정에 변동이 있어요 → "예상 출퇴근 시간을 알려주세요" (.setEstimateTime)
            dismiss(animated: true) { [weak self] in
                self?.presentWorkingScheduleAdjustBottomSheet()
            }
        }
    }

    func workScheduleChangeBottomSheetDidCancel(_ sheet: WorkScheduleChangeBottomSheet) {
        dismiss(animated: true)
    }
}
