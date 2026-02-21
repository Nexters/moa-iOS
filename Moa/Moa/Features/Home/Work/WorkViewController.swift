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
}

// MARK: - WorkViewController

final class WorkViewController: BaseViewController {

    // MARK: - Constants

    private enum Constant {
        static let earlyWork = "일찍 출근하기"
        static let todayVacation = "오늘 휴가예요"
        static let navigationBarHeight: CGFloat = 44
    }

    // MARK: - Properties

    private let viewModel: WorkViewModel
    private var hasShownWorkAlarmSheet = false
    private var workingTimer: Timer?

    override var prefersNavigationBarHidden: Bool { true }

    /// Coordinator가 주입하는 델리게이트
    weak var coordinatorDelegate: WorkViewControllerCoordinatorDelegate?

    private let contentView = UIView()

    // 네비게이션
    private let navigationBarView = HomeNavigationBarView()

    // 근무 전 콘텐츠
    private lazy var beforeWorkingView: BeforeWorkingContentView = {
        let view = BeforeWorkingContentView()
        view.delegate = self
        return view
    }()

    // 근무 중 콘텐츠
    private lazy var workingStatusView = WorkingContentView(workingType: .work)

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

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.send(.viewDidLoad)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showWorkAlarmBottomSheetIfNeeded()
    }

    override func setupUI() {
        view.backgroundColor = AppColor.Background.primary
        replaceSystemBackButtonWithAppBackButton()
        setupHierarchy()
        setupConstraints()

        // 네비게이션 바 캘린더 아이콘 탭 연결
        navigationBarView.onCalendarTap = { [weak self] in
            guard let self else { return }
            self.coordinatorDelegate?.workViewControllerDidTapCalendar(self)
        }
    }

    override func bind() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.render(state)
            }
            .store(in: &cancellables)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopWorkingTimer()
    }
}

// MARK: - Layout

private extension WorkViewController {

    func setupHierarchy() {
        view.addSubViews([contentView, loadingIndicator])
        contentView.addSubViews([navigationBarView, beforeWorkingView, workingStatusView])
    }

    func setupConstraints() {
        contentView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }

        navigationBarView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(Constant.navigationBarHeight)
        }

        beforeWorkingView.snp.makeConstraints {
            $0.top.equalTo(navigationBarView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
            $0.bottom.equalToSuperview()
        }

        workingStatusView.snp.makeConstraints {
            $0.top.equalTo(navigationBarView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
            $0.bottom.equalToSuperview()
        }

        loadingIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}

// MARK: - Render

private extension WorkViewController {

    func render(_ state: WorkViewState) {
        switch state {
        case .idle:   break
        case .loading:            renderLoading()
        case .loaded(let data):   renderLoaded(data)
        case .error(let error):   renderError(error)
        }
    }

    func renderLoading() {
        loadingIndicator.startAnimating()
        beforeWorkingView.isHidden = true
        workingStatusView.isHidden = true
    }

    func renderLoaded(_ data: HomeViewData) {
        loadingIndicator.stopAnimating()
        updateMonthlySalary(data.monthlyInfo)

        switch data.workStatus {
        case .beforeWork:               renderBeforeWork(data)
        case .working(let startedAt):   renderWorking(data, startedAt: startedAt)
        }
    }

    func renderError(_ error: HomeError) {
        loadingIndicator.stopAnimating()
        showErrorAlert(message: error.localizedDescription)
    }

    func renderBeforeWork(_ data: HomeViewData) {
        stopWorkingTimer()
        beforeWorkingView.isHidden = false
        workingStatusView.isHidden = true
        beforeWorkingView.configure(
            monthlyInfo: data.monthlyInfo,
            workTime: data.workTime,
            wage: data.wage
        )
    }

    func renderWorking(_ data: HomeViewData, startedAt: Date) {
        beforeWorkingView.isHidden = true
        workingStatusView.isHidden = false
        workingStatusView.configure(
            todayAmount: 12_000,
            startTime: "09:00",
            endTime: "18:00",
            startedAt: startedAt
        )
        startWorkingTimer()
    }

    func updateMonthlySalary(_ info: MonthlyInfo) {}
}

// MARK: - Working Timer

private extension WorkViewController {

    func startWorkingTimer() {
        stopWorkingTimer()
        workingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.workingStatusView.tick()
        }
    }

    func stopWorkingTimer() {
        workingTimer?.invalidate()
        workingTimer = nil
    }
}

// MARK: - Actions

private extension WorkViewController {

    @objc func didTapMainButton() {
        viewModel.send(.startWork)
    }

    @objc func didTapVacation() {
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

// MARK: - Bottom Sheets

private extension WorkViewController {

    func showWorkAlarmBottomSheetIfNeeded() {
        guard !hasShownWorkAlarmSheet else { return }
        let hasUserDismissedPermanently = UserDefaults.standard.bool(forKey: "HasDismissedWorkAlarmSheet")
        guard !hasUserDismissedPermanently else { return }
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
        let sheet = TimeSelectionBottomSheet(
            type: .setEstimateTime,
            startTime: data.workTime.start,
            endTime: data.workTime.end
        )
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
}

// MARK: - WorkAlarmBottomSheetDelegate

extension WorkViewController: WorkAlarmBottomSheetDelegate {

    func didTapAlarm() { requestNotificationPermission() }
    func didTapLater() {}

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
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

// MARK: - WorkingStatusViewDelegate

extension WorkViewController: WorkingStatusViewDelegate {
    func workingStatusViewDidTapScheduleAdjust(_ view: WorkingStatusView) {
        presentTimeSelectionBottomSheet()
    }
}

// MARK: - BeforeWorkingViewDelegate

extension WorkViewController: BeforeWorkingViewDelegate {

    func beforeWorkingViewDidTapStartWork(_ view: BeforeWorkingContentView) {
        viewModel.send(.startWork)
    }
    func beforeWorkingViewDidTapVacation(_ view: BeforeWorkingContentView) {
        didTapVacation()
    }
    func beforeWorkingViewDidRequestTimeSelection(_ view: BeforeWorkingContentView) {
        presentTimeSelectionBottomSheet()
    }
}

// MARK: - Preview

@available(iOS 17.0, *)
#Preview {
    WorkViewController(viewModel: WorkViewModel())
}
