//
//  WithdrawalViewController.swift
//  Moa
//
//  Created by mirim on 2/24/26.
//

import UIKit
import SnapKit

final class WithdrawalViewController: BaseViewController {
    
    private enum Constants {
        static let navigationTitle = "회원 탈퇴"
        static let subtitle = "헤어지게 되어 아쉬워요.."
        static let title = "탈퇴 사유를 알려주시면\n더 나은 서비스를 제공하기 위해\n노력할게요."
        static let withdrawalButton = "탈퇴 하기"
        static let reasons = [
            "앱 오류로 사용하기 불편해요",
            "원하는 기능이 부족해요",
            "서비스 이용이 복잡하거나 불편해요",
            "급여 계산이 실제와 달라요",
            "자주 사용하지 않아요",
            "개인정보 · 보안이 걱정돼요"
        ]
    }
    
    private let viewModel: WithdrawalViewModel
    
    // MARK: - UI Components
    
    private let subtitleLabel: StyledLabel = {
        let label = StyledLabel()
        label.setText(
            Constants.subtitle,
            style: .init(
                typography: AppTypography.b2_400,
                color: AppColor.IconAndText.mediumEmphasis
            )
        )
        return label
    }()
    
    private let titleLabel: StyledLabel = {
        let label = StyledLabel()
        label.setText(
            Constants.title,
            style: .init(
                typography: AppTypography.t1_700,
                color: AppColor.IconAndText.highEmphasis
            )
        )
        label.numberOfLines = 0
        return label
    }()
    
    private let headerStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }()
    
    // 재사용 가능한 row들을 담는 스택
    private let reasonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 24
        return stack
    }()
    
    private let withdrawalButton: AppButton = {
        let button = AppButton()
        button.setTitle(Constants.withdrawalButton, for: .normal)
        button.applyStyle(.primary())
        return button
    }()
    
    // row 뷰 참조 보관
    private var reasonRows: [WithdrawalReasonRowView] = []
    
    init(viewModel: WithdrawalViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    override func setupUI() {
        replaceSystemBackButtonWithAppBackButton()
        setupNavigationTitle(as: Constants.navigationTitle)
        
        headerStack.addArrangedSubview(subtitleLabel)
        headerStack.addArrangedSubview(titleLabel)
        
        // row 생성 및 스택에 추가
        Constants.reasons.forEach { reason in
            let row = WithdrawalReasonRowView(title: reason)
            row.onTap = { [weak self, weak row] in
                guard let self, let row else { return }
                
                self.reasonRows
                    .filter { $0 !== row }
                    .forEach { $0.isSelected = false }
                
                row.toggle()
                self.updateWithdrawalButtonState()
            }
            reasonRows.append(row)
            reasonStack.addArrangedSubview(row)
        }
        
        view.addSubViews([headerStack, reasonStack, withdrawalButton])
        
        headerStack.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
        }
        
        reasonStack.snp.makeConstraints { make in
            make.top.equalTo(headerStack.snp.bottom).offset(36)
            make.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
        }
        
        withdrawalButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(AppSpacing.ctaBottom)
            make.height.greaterThanOrEqualTo(64)
        }
        
        withdrawalButton.addTarget(self, action: #selector(withdrawalButtonTapped), for: .touchUpInside)
        
        updateWithdrawalButtonState()
    }
    
    // MARK: - Private
    
    private func updateWithdrawalButtonState() {
        let isEnabled = reasonRows.contains { $0.isSelected }
        withdrawalButton.isEnabled = isEnabled
    }
    
    // MARK: - Actions
    
    @objc private func withdrawalButtonTapped() {
        let selectedReasons = reasonRows
            .filter { $0.isSelected }
            .compactMap { $0.titleLabel.text }
        
        Task {
            do {
                try await viewModel.withdrawalButtonTapped(reason: selectedReasons)
                NotificationCenter.default.post(name: .didLogoutOrWithdrawal, object: nil)
            } catch {
                ToastManager.show(message: "회원 탈퇴에 실패했습니다.")
            }
        }
    }
}
