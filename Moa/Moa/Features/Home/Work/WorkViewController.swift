//
//  WorkViewController.swift
//  Moa
//
//  Created by 정도현 on 2/1/26.
//

import UIKit
import Combine
import SnapKit

// MARK: - CoordinatorDelegate

protocol WorkViewControllerCoordinatorDelegate: AnyObject {
    func workViewControllerDidTapCalendar(_ viewController: WorkViewController)
    func workViewControllerDidTapSetting(_ viewController: WorkViewController)
}

// MARK: - WorkViewController

final class WorkViewController: BaseViewController {

    private enum Constant {
        static let navigationBarHeight: CGFloat = 44
    }

    // MARK: - Properties

    private let viewModel: WorkViewModel
    private var hasShownWorkAlarmSheet = false
    private var workingTimer: Timer?

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

    init(viewModel: WorkViewModel = WorkViewModel()) {
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
        // 캘린더 이탈 후 재진입 시 타이머 재시작
        // viewWillDisappear에서 stopWorkingTimer()로 중단됐기 때문에 재시작 필요 (시간 동기화)
        if case .loaded(let data) = viewModel.state, data.workStatus.isActive {
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
        case .idle:             break
        case .loading:          renderLoading()
        case .loaded(let data): renderLoaded(data)
        case .error(let error): renderError(error)
        }
    }

    func renderLoading() {
        loadingIndicator.startAnimating()
        workMainView.isHidden       = true
        workingContentView.isHidden = true
    }

    func renderLoaded(_ data: HomeDisplayData) {
        loadingIndicator.stopAnimating()
        switch data.workStatus {
        case .idle, .finished:
            renderMainView(data)
        case .working(let startedAt):
            renderActiveWork(data, startedAt: startedAt, workingType: .work)
        case .onVacation(let startedAt):
            renderActiveWork(data, startedAt: startedAt, workingType: .vacation)
        }
    }

    func renderMainView(_ data: HomeDisplayData) {
        stopWorkingTimer()
        workingContentView.stopAnimations()

        workMainView.isHidden       = false
        workingContentView.isHidden = true
        workMainView.configure(with: data)
    }

    func renderActiveWork(_ data: HomeDisplayData, startedAt: Date, workingType: WorkingType) {
        workMainView.isHidden       = true
        workingContentView.isHidden = false

        // 현재 경과 초 기준 초기 금액 계산
        let elapsed     = max(0, Int(Date().timeIntervalSince(startedAt)))
        let todayAmount = Int(Double(data.hourlyWage) * Double(elapsed) / 3600.0)

        workingContentView.configure(
            todayAmount:  todayAmount,
            hourlyWage:   data.hourlyWage,
            startTime:    data.scheduledClockIn,
            endTime:      data.scheduledClockOut,
            startedAt:    startedAt,
            workingType:  workingType
        )

        // 항상 재시작 (viewWillDisappear 후 재진입 포함)
        startWorkingTimer()
    }

    func renderError(_ error: WorkViewError) {
        loadingIndicator.stopAnimating()
        showErrorAlert(message: error.localizedDescription ?? "")
    }
}

// MARK: - Timer

private extension WorkViewController {

    func startWorkingTimer() {
        stopWorkingTimer()  // 기존 타이머 정리 후 새로 시작
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

    func showWorkAlarmBottomSheetIfNeeded() {
        guard !hasShownWorkAlarmSheet,
              !UserDefaults.standard.bool(forKey: "HasDismissedWorkAlarmSheet")
        else { return }
        hasShownWorkAlarmSheet = true
        DispatchQueue.main.async { [weak self] in self?.showWorkAlarmBottomSheet() }
    }

    func showWorkAlarmBottomSheet() {
        let vc = WorkAlarmBottomSheet()
        vc.delegate = self
        presentBottomSheet(vc)
    }

    func presentTimeSelectionBottomSheet() {
        guard case .loaded(let data) = viewModel.state else { return }
        let present = { [weak self] in
            guard let self else { return }
            let sheet = TimeSelectionBottomSheet(
                type: .setEstimateTime,
                startTime: data.scheduledClockIn,
                endTime:   data.scheduledClockOut
            )
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
                else if let error { print("알림 권한 오류: \(error.localizedDescription)") }
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
        viewModel.send(.updateWorkTime(start: startTime, end: endTime))
    }
}

// MARK: - WorkingContentViewDelegate

extension WorkViewController: WorkingContentViewDelegate {

    func workingContentViewDidTapScheduleAdjust(_ view: WorkingContentView) {
        presentScheduleChangeBottomSheet()
    }
}

// MARK: - WorkMainContentViewDelegate

extension WorkViewController: WorkMainContentViewDelegate {

    func workMainContentViewDidTapPrimaryAction(_ view: WorkMainContentView) {
        viewModel.send(.startWork)
    }

    func workMainContentViewDidTapVacation(_ view: WorkMainContentView) {
        showVacationConfirmAlert()
    }

    func workMainContentViewDidRequestTimeSelection(_ view: WorkMainContentView) {
        presentTimeSelectionBottomSheet()
    }

    func workMainContentViewDidTapWorkHistory(_ view: WorkMainContentView) {
        coordinatorDelegate?.workViewControllerDidTapCalendar(self)
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
            dismiss(animated: true) { [weak self] in self?.viewModel.send(.endWork) }
        case .changeSchedule:
            dismiss(animated: true) { [weak self] in self?.presentTimeSelectionBottomSheet() }
        }
    }

    func workScheduleChangeBottomSheetDidCancel(_ sheet: WorkScheduleChangeBottomSheet) {
        dismiss(animated: true)
    }
}
