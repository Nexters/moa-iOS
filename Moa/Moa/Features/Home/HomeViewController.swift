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
        static let autoWorkSuffix = "자동 출근 예정"
        static let earlyWork = "일찍 출근하기"
        static let todayVacation = "오늘 휴가예요"
        
        static let navigationBarHeight: CGFloat = 56
        static let salaryInset: CGFloat = 17
        static let actionSpacing: CGFloat = 16
        static let bottomInset: CGFloat = 24
        static let scrollBottomInset: CGFloat = 200
    }
    
    // MARK: - Properties
    
    private let viewModel: HomeViewModel
    private var hasShownWorkAlarmSheet = false
    
    override var prefersNavigationBarHidden: Bool { true }
    
    // MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private let contentView = UIView()
    
    private let navigationBarView = HomeNavigationBarView()
    
    // Main Info Group
    private let mainInfoContainerView = UIView()
    
    private lazy var dateLocationInfoView: DateLocationInfoView = {
        let view = DateLocationInfoView(
            date: getCurrentDateString(),
            location: ""
        )
        return view
    }()
    
    private let moneyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .Image.imageEmptyMoney)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var monthlySalaryView: MonthlySalaryView = {
        let view = MonthlySalaryView(
            month: 2,
            amount: 0,
            baseAmount: 0,
            shouldAnimate: false
        )
        return view
    }()
    
    private lazy var todayWorkSummaryView: TodayWorkSummaryView = {
        let view = TodayWorkSummaryView()
        view.onTapTimeRow = { [weak self] in
            self?.presentTimeSelectionBottomSheet()
        }
        return view
    }()
    
    // Bottom Action Group
    private let bottomActionContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColor.Background.primary
        return view
    }()
    
    private lazy var autoWorkIndicator: SpeechBubble = {
        let view = SpeechBubble(text: "")
        view.isHidden = true
        return view
    }()
    
    private lazy var startWorkButton: AppButton = {
        let button = AppButton()
        button.setTitle(Constant.earlyWork, for: .normal)
        button.applyStyle(.primary())
        button.addTarget(self, action: #selector(didTapStartWork), for: .touchUpInside)
        return button
    }()
    
    private lazy var underlineButton: UnderlineTextButton = {
        let button = UnderlineTextButton(title: Constant.todayVacation)
        button.addTarget(self, action: #selector(didTapVacation), for: .touchUpInside)
        return button
    }()
    
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
            scrollView,
            bottomActionContainerView,
            loadingIndicator
        ])
        
        scrollView.addSubview(contentView)
        
        contentView.addSubViews([
            navigationBarView,
            mainInfoContainerView,
            todayWorkSummaryView
        ])
        
        mainInfoContainerView.addSubViews([
            dateLocationInfoView,
            moneyImageView,
            monthlySalaryView
        ])
        
        bottomActionContainerView.addSubViews([
            autoWorkIndicator,
            startWorkButton,
            underlineButton
        ])
    }
    
    func setupConstraints() {
        // Scroll View
        scrollView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
        }
        
        // Navigation
        navigationBarView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(Constant.navigationBarHeight)
        }
        
        // Main Info Group
        mainInfoContainerView.snp.makeConstraints {
            $0.top.equalTo(navigationBarView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview()
        }
        
        dateLocationInfoView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
        
        moneyImageView.snp.makeConstraints {
            $0.top.equalTo(dateLocationInfoView.snp.bottom).offset(28)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(80)
        }
        
        monthlySalaryView.snp.makeConstraints {
            $0.top.equalTo(moneyImageView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(Constant.salaryInset)
            $0.bottom.equalToSuperview()
        }
        
        // Summary
        todayWorkSummaryView.snp.makeConstraints {
            $0.top.equalTo(mainInfoContainerView.snp.bottom).offset(36)
            $0.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
            $0.bottom.equalToSuperview().inset(Constant.scrollBottomInset)
        }
        
        // Bottom Action Group
        bottomActionContainerView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        autoWorkIndicator.snp.makeConstraints {
            $0.top.equalToSuperview().inset(12)
            $0.centerX.equalToSuperview()
        }
        
        startWorkButton.snp.makeConstraints {
            $0.top.equalTo(autoWorkIndicator.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
        }
        
        underlineButton.snp.makeConstraints {
            $0.top.equalTo(startWorkButton.snp.bottom).offset(Constant.actionSpacing)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(Constant.bottomInset)
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
        todayWorkSummaryView.isHidden = true
        startWorkButton.isEnabled = false
    }
    
    func renderLoaded(_ data: HomeViewData) {
        loadingIndicator.stopAnimating()
        todayWorkSummaryView.isHidden = false
        startWorkButton.isEnabled = true
        
        // Update UI
        updateDateLocationInfo(data.location)
        updateMonthlySalary(data.monthlyInfo)
        updateTodayWorkSummary(data)
        updateAutoWorkIndicator(data.autoWorkText)
    }
    
    func renderError(_ error: HomeError) {
        loadingIndicator.stopAnimating()
        startWorkButton.isEnabled = false
        
        showErrorAlert(message: error.localizedDescription)
    }
    
    func updateDateLocationInfo(_ location: LocationInfo) {
        
    }
    
    func updateMonthlySalary(_ info: MonthlyInfo) {
        
    }
    
    func updateTodayWorkSummary(_ data: HomeViewData) {
        todayWorkSummaryView.configure(
            wage: data.wage,
            startTime: data.workTime.start.displayString,
            endTime: data.workTime.end.displayString
        )
    }
    
    func updateAutoWorkIndicator(_ text: String) {
        autoWorkIndicator.isHidden = false
    }
}

// MARK: - Actions

private extension HomeViewController {
    
    @objc
    func didTapStartWork() {
        viewModel.send(.startWork)
    }
    
    @objc
    func didTapVacation() {
        showVacationConfirmation()
    }
    
    func showVacationConfirmation() {
        
        
    }
}

// MARK: - Bottom Sheets

private extension HomeViewController {
    
    func showWorkAlarmBottomSheetIfNeeded() {
        guard !hasShownWorkAlarmSheet else { return }
        
        // TODO: USER DEFAULT
        let hasUserDismissedPermanently = UserDefaults.standard.bool(forKey: "HasDismissedWorkAlarmSheet")
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

// MARK: - Helpers

private extension HomeViewController {
    
    func getCurrentDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일 EEEE"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: Date())
    }
}

// MARK: - WorkAlarmBottomSheetDelegate

extension HomeViewController: WorkAlarmBottomSheetDelegate {
    
    func didTapAlarm() {
        requestNotificationPermission()
    }
    
    func didTapLater() {
        // 나중에 다시 보기 - 아무 작업 없음
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    print("알림 권한 승인됨")
                } else if let error = error {
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
