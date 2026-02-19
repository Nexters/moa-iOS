//
//  SettingHomeViewController.swift
//  Moa
//
//  Created by mirim on 2/19/26.
//

import UIKit
import SnapKit

final class SettingHomeViewController: BaseViewController {
    
    // MARK: - Dependencies
    
    private let viewModel = SettingHomeViewModel()
    
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
    
    // MARK: - Init
    
    
    // MARK: - Setup
    
    override func setupUI() {
        replaceSystemBackButtonWithAppBackButton()
        
        view.addSubViews([memberInfoStack])
        
        memberInfoStack.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(AppSpacing.screenHorizontal)
        }
        
        // api 연결 후 수정
        accountProviderLabel.setText(viewModel.accountProvider.displayName)
        nicknameLabel.setText(viewModel.nickname)
    }
    
    override func setupActions() {
        
    }
}
