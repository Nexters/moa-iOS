//
//  SettingHomeViewController.swift
//  Moa
//
//  Created by mirim on 2/19/26.
//

import UIKit
import SnapKit
import SafariServices


final class SettingHomeViewController: BaseViewController {
    
    // MARK: - Dependencies
    
    private let coordinator: SettingCoordinator
    private let viewModel: SettingHomeViewModel
    
    // MARK: - Constants
    
    private enum Constants {
        static let setting = "설정"
        static let myInfo = "내 정보"
        static let salaryWorkPolicyInfo = "월급 · 근무 정보 "
        static let appSetting = "앱 설정"
        static let notificationSetting = "알림 설정"
        static let appInfoOrHelp = "앱 정보 및 도움말"
        static let versionInfo = "버전 정보"
        static let updatedRequired = "업데이트 필요"
        static let latestVersion = "최신 버전"
        static let termsAndPolicy = "약관 및 정책"
        static let inquiry = "문의하기"
        static let logout = "로그아웃"
        static let withdrawal = "회원탈퇴"
        static let appstoreId = "6758913984"
    }
    
    // MARK: - UI Components
    
    private lazy var memberInfoStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.distribution = .fill
        stack.alignment = .leading
        stack.addArrangedSubViews([accountProviderLabel, nicknameStack])
        return stack
    }()
    
    private lazy var nicknameStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fill
        stack.addArrangedSubViews([nicknameLabel, nicknameEditButton])
        return stack
    }()
    
    private let logoutLeadingSpacer: UIView = {
        let v = UIView()
        v.setContentHuggingPriority(.defaultLow, for: .horizontal)
        v.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return v
    }()

    private let logoutTrailingSpacer: UIView = {
        let v = UIView()
        v.setContentHuggingPriority(.defaultLow, for: .horizontal)
        v.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return v
    }()
    
    private lazy var logOutAndWithdrawalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 16
        stack.distribution = .fill
        stack.addArrangedSubViews([logoutLeadingSpacer, logoutButton, VerticalDividerView(height: 11.5), withdrawalButton, logoutTrailingSpacer])
        return stack
    }()
    
    private let logoutButton: UIButton = {
        var config = UIButton.Configuration.plain()
        var title = AttributedString(Constants.logout)
        title.font = AppTypography.b1_500.font()
        title.foregroundColor = AppColor.IconAndText.mediumEmphasis
        config.attributedTitle = title
        config.titleAlignment = .trailing
        config.contentInsets = .zero
        
        let button = UIButton(configuration: config)
        return button
    }()
    
    private let withdrawalButton: UIButton = {
        var config = UIButton.Configuration.plain()
        var title = AttributedString(Constants.withdrawal)
        title.font = AppTypography.b1_500.font()
        title.foregroundColor = AppColor.IconAndText.mediumEmphasis
        config.attributedTitle = title
        config.titleAlignment = .leading
        config.contentInsets = .zero
        
        let button = UIButton(configuration: config)
        return button
    }()
    
    private let accountProviderLabel: StyledLabel = {
        let label = StyledLabel()
        label.setStyle(
            .init(
                typography: AppTypography.b2_400,
                color: AppColor.IconAndText.mediumEmphasis
            )
        )
        return label
    }()
    
    private let nicknameLabel: StyledLabel = {
        let label = StyledLabel()
        label.setStyle(
            .init(
                typography: AppTypography.t1_700,
                color: AppColor.IconAndText.green
            )
        )
        return label
    }()
    
    private let nicknameEditButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(resource: .Icon.iconEdit), for: .normal)
        return btn
    }()
    
    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 24
        return stack
    }()
    
    private lazy var versionInfoRow = SettingItemRowView(
        title: Constants.versionInfo,
        subtitle: "",
        value: Constants.latestVersion,
        showsChevron: false
    )
    
    // MARK: - Init
    
    init(
        coordinator: SettingCoordinator,
        viewModel: SettingHomeViewModel
    ) {
        self.coordinator = coordinator
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        setupNavigationTitle(as: Constants.setting)
        configureContentStack()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - App LifeCycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.viewAppeared()
    }
    
    // MARK: - Setup
    
    override func setupUI() {
        replaceSystemBackButtonWithAppBackButton()
        
        view.addSubViews([memberInfoStack, contentStack, logOutAndWithdrawalStack])
        
        memberInfoStack.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(AppSpacing.screenHorizontal)
        }
        
        contentStack.snp.makeConstraints { make in
            make.top.equalTo(memberInfoStack.snp.bottom).offset(32)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(AppSpacing.screenHorizontal)
        }
        
        logOutAndWithdrawalStack.snp.makeConstraints { make in
            make.top.equalTo(contentStack.snp.bottom).offset(24)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(AppSpacing.screenHorizontal)
        }
        
        logOutAndWithdrawalStack.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        logoutLeadingSpacer.snp.makeConstraints { make in
            make.width.equalTo(logoutTrailingSpacer)
        }
    }
    
    func configureContentStack() {
        let myInfoRow = SettingItemRowView(
            title: Constants.salaryWorkPolicyInfo
        )
        
        let notificationRow = SettingItemRowView(
            title: Constants.notificationSetting
        )
        notificationRow.onTap = { }
        
        let termsAndPolicy = SettingItemRowView(
            title: Constants.termsAndPolicy
        )
        
        termsAndPolicy.onTap = { [weak self] in
            guard let self else { return }
            self.coordinator.moveToTermsAndPolicy()
        }
        
        let inquiry = SettingItemRowView(
            title: Constants.inquiry
        )
        inquiry.onTap = { [weak self] in
            guard let self else { return }
            self.openInquiryForm()
        }
        
        contentStack.addArrangedSubViews([
            SettingSectionView(
                title: Constants.myInfo,
                rows: [myInfoRow],
                onRowTap: { [weak self] _ in
                    guard let self else { return }
                    self.coordinator.moveToPayrollWorkPolicyInfo(accountProvider: viewModel.accountProvider)
                }
            ),
            SettingSectionView(
                title: Constants.appSetting,
                rows: [notificationRow],
                onRowTap: { [weak self] _ in
                    self?.coordinator.moveToNotificationSetting()
                }
            ),
            SettingSectionView(
                title: Constants.appInfoOrHelp,
                rows: [
                    versionInfoRow,
                    termsAndPolicy,
                    inquiry
                ],
                onRowTap: { [weak self] index in
                    
                }
            )
        ])
    }
    
    override func setupActions() {
        nicknameEditButton.addTarget(self, action: #selector(nicknameEditButtonTapped), for: .touchUpInside)
        logoutButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        withdrawalButton.addTarget(self, action: #selector(withdrawalButtonTapped), for: .touchUpInside)
    }
    
    @objc private func nicknameEditButtonTapped() {
        coordinator.moveToNicknameEdit(currentNickname: viewModel.nickname)
    }
    
    override func bind() {
        bindOutput(viewModel.outputs) { [weak self] output in
            guard let self else { return }
            
            switch output {
            case .memberFetched:
                accountProviderLabel.setText(viewModel.accountProvider.displayName)
                
            case .profileFetched:
                nicknameLabel.setText(viewModel.nickname)
                
            case .versionFetched:
                updateVersionRow()
                
            case .logoutSucceed:
                NotificationCenter.default.post(name: .didLogoutOrWithdrawal, object: nil)
            }
        }
    }
    
    func openAppStore() {
        guard let url = URL(string: "https://apps.apple.com/app/id\(Constants.appstoreId)") else { return }
        UIApplication.shared.open(url)
    }
    
    private func updateVersionRow() {
        versionInfoRow.updateSubtitle("v\(viewModel.currentVersion)")
        
        switch viewModel.versionStatus {
        case .latest:
            versionInfoRow.updateValue(Constants.latestVersion)
            versionInfoRow.setChevronVisible(false)
            versionInfoRow.onTap = nil
        case .updateRequired:
            versionInfoRow.updateValue(Constants.updatedRequired)
            versionInfoRow.setChevronVisible(true)
            versionInfoRow.onTap = { [weak self] in
                self?.openAppStore()
            }
        }
    }
    
    private func openInquiryForm() {
        guard let url = URL(string: "https://forms.gle/cvjVQuNpctzs1p2QA") else { return }
        
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true)
    }
    
    @objc private func logoutButtonTapped() {
        AlertManager.show(
            title: "로그아웃 하시겠어요?",
            subtitle: "로그아웃하면 로그인 화면으로 이동해요.",
            leftButtonTitle: "취소",
            rightButtonTitle: "확인",
            onRightButtonTapped: { [weak self] in
                self?.viewModel.logout()
            }
        )
    }
    
    @objc private func withdrawalButtonTapped() {
        coordinator.moveToWithdrawal()
    }
}

