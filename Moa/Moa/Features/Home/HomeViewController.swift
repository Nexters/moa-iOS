//
//  HomeViewController.swift
//  Moa
//
//  Created by 정도현 on 2/1/26.
//

import UIKit
import Combine
import SnapKit

final class HomeViewController: BaseViewController {

    // MARK: - Constants

    private enum Constant {
        static let earlyWork = "일찍 출근하기"
        static let todayVacation = "오늘 휴가예요"

        static let navigationBarHeight: CGFloat = 44
    }

    // MARK: - Properties

    private let viewModel: HomeViewModel
    private var hasShownWorkAlarmSheet = false
    private var workingTimer: Timer?

    override var prefersNavigationBarHidden: Bool { true }

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
    private lazy var workingStatusView = WorkingContentView(workingType: .vacation)
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Init

    init(viewModel: HomeViewModel = HomeViewModel()) {
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
        
        setupHierarchy()
        setupConstraints()
    }

    override func bind() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.render(state)
            }
            .store(in: &cancellables)
    }
}

// MARK: - Layout

private extension HomeViewController {

    func setupHierarchy() {
        view.addSubViews([
            contentView,
            loadingIndicator
        ])

        contentView.addSubViews([
            navigationBarView,
            beforeWorkingView,
            workingStatusView
        ])
    }

    func setupConstraints() {
        
        contentView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }

        // Navigation (항상 표시)
        navigationBarView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(Constant.navigationBarHeight)
        }

        beforeWorkingView.snp.makeConstraints {
            $0.top.equalTo(navigationBarView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
            $0.bottom.equalToSuperview()
        }

        // 근무 중 뷰 (같은 위치, 상태에 따라 토글)
        workingStatusView.snp.makeConstraints {
            $0.top.equalTo(navigationBarView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
            $0.bottom.equalToSuperview()
        }

        // Loading Indicator
        loadingIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}

// MARK: - Render

private extension HomeViewController {

    func render(_ state: HomeViewState) {
        switch state {
        case .idle:
            break

        case .loading:
            renderLoading()

        case .loaded(let data):
            renderLoaded(data)

        case .error(let error):
            renderError(error)
        }
    }

    func renderLoading() {
        loadingIndicator.startAnimating()
        beforeWorkingView.isHidden = true
        workingStatusView.isHidden = true
    }

    func renderLoaded(_ data: HomeViewData) {
        loadingIndicator.stopAnimating()

        // 공통 UI 업데이트 (항상 표시되는 영역)
        updateMonthlySalary(data.monthlyInfo)

        // 상태에 따라 UI 분기
        switch data.workStatus {
        case .beforeWork:
            renderBeforeWork(data)

        case .working(let startedAt):
            renderWorking(data, startedAt: startedAt)
        }
    }

    func renderError(_ error: HomeError) {
        loadingIndicator.stopAnimating()
        showErrorAlert(message: error.localizedDescription)
    }

    // MARK: - 근무 전

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

    // MARK: - 근무 중

    func renderWorking(_ data: HomeViewData, startedAt: Date) {
        
        beforeWorkingView.isHidden = true
        workingStatusView.isHidden = false

        workingStatusView.configure(
            todayAmount: 12_000,           // 오늘 누적 월급
            startTime: "09:00",
            endTime: "18:00",
            startedAt: startedAt
        )

        // 바텀 버튼 영역
        startWorkingTimer()
    }

    // MARK: - 공통 업데이트

    func updateMonthlySalary(_ info: MonthlyInfo) {
//        monthlySalaryView.updateAmount(
//            month: info.month,
//            amount: info.currentAmount,
//            baseAmount: info.baseAmount,
//            animated: true
//        )
    }
}

// MARK: - Working Timer

private extension HomeViewController {

    func startWorkingTimer() {
        stopWorkingTimer()
        workingTimer = Timer.scheduledTimer(
            withTimeInterval: 1.0,
            repeats: true
        ) { [weak self] _ in
            self?.workingStatusView.tick()
        }
    }

    func stopWorkingTimer() {
        workingTimer?.invalidate()
        workingTimer = nil
    }
}

// MARK: - Actions

private extension HomeViewController {

    @objc
    func didTapMainButton() {
        viewModel.send(.startWork)
    }

    @objc
    func didTapVacation() {
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

private extension HomeViewController {

    func showWorkAlarmBottomSheetIfNeeded() {
        guard !hasShownWorkAlarmSheet else { return }

        let hasUserDismissedPermanently = UserDefaults.standard.bool(
            forKey: "HasDismissedWorkAlarmSheet"
        )
        guard !hasUserDismissedPermanently else { return }

        hasShownWorkAlarmSheet = true

        DispatchQueue.main.async { [weak self] in
            self?.showWorkAlarmBottomSheet()
        }
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
        
        print("HI")
        
        
        sheet.delegate = self
        presentBottomSheet(sheet)
    }
}

// MARK: - Alert

private extension HomeViewController {

    func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "오류",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - WorkAlarmBottomSheetDelegate

extension HomeViewController: WorkAlarmBottomSheetDelegate {

    func didTapAlarm() {
        requestNotificationPermission()
    }

    func didTapLater() {
        // 나중에 다시 보기
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    print("알림 권한 승인됨")
                } else if let error {
                    print("알림 권한 오류: \(error.localizedDescription)")
                }
            }
        }
    }
}

// MARK: - TimeSelectionBottomSheetDelegate

extension HomeViewController: TimeSelectionBottomSheetDelegate {

    func timeSelectionBottomSheet(
        _ sheet: TimeSelectionBottomSheet,
        didConfirmStartTime startTime: TimeIndicatorEntity,
        endTime: TimeIndicatorEntity
    ) {
        viewModel.send(.updateWorkTime(start: startTime, end: endTime))
    }
}


// 일정 조정 버튼 → 시간 선택 바텀시트 재활용
extension HomeViewController: WorkingStatusViewDelegate {
    func workingStatusViewDidTapScheduleAdjust(_ view: WorkingStatusView) {
        presentTimeSelectionBottomSheet()
    }
}

// 근무 전 상태 뷰
extension HomeViewController: BeforeWorkingViewDelegate {

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


@available(iOS 17.0)
#Preview {
    HomeViewController(viewModel: HomeViewModel())
}
