//
//  OnboardingSalaryViewController.swift
//  Moa
//
//  Created by mirim on 2/3/26.
//

import UIKit
import SnapKit

final class OnboardingSalaryViewController: BaseViewController {
    // MARK: - Constants
    
    private enum Constant {
        static let title = "얼마씩 받고 있나요?"
        static let subtitle = "세전, 세후 상관없이 보고 싶은 금액을 입력해주세요."
        static let salaryType = "급여 유형"
        static let amount = "금액"
        static let won = "원"
    }
    
    // MARK: - State
    private var selectedSalaryType: SalaryType = .monthly {
        didSet { applySalaryTypeSelection() }
    }
    
    // MARK: - Dependencies
    
    private let viewModel: OnboardingSalaryViewModel
    private let onNext: (() -> Void)
    
    // MARK: - UI Components
    
    /// "얼마씩 받고 있나요?"
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = Constant.title
        label.applyTextStyle(.init(
            typography: AppTypography.t1_700,
            color: AppColor.IconAndText.highEmphasis
        ))
        return label
    }()
    
    /// "세전, 세후 상관없이 보고 싶은 금액을 입력해주세요."
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.text = Constant.subtitle
        label.applyTextStyle(.init(
            typography: AppTypography.b2_400,
            color: AppColor.IconAndText.mediumEmphasis
        ))
        return label
    }()
    
    private let salaryTypeLabel: UILabel = {
        let label = UILabel()
        label.text = Constant.salaryType
        label.applyTextStyle(.init(
            typography: AppTypography.b2_500,
            color: AppColor.IconAndText.mediumEmphasis
        ))
        return label
    }()
    
    private let optionStack: UIStackView = {
        let v = UIStackView()
        v.axis = .horizontal
        v.spacing = 12.0
        v.alignment = .fill
        v.distribution = .fillEqually
        return v
    }()
    
    private let monthlyButton = OptionChipButton(title: SalaryType.monthly.rawValue)
    private let annualButton = OptionChipButton(title: SalaryType.annual.rawValue)
    
    private let nextButton = AppButton()
    
    // MARK: - Init
    
    init(
        viewModel: OnboardingSalaryViewModel,
        onNext: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.onNext = onNext
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    override func setupUI() {
        replaceSystemBackButtonWithAppBackButton()
        setupHierarchy()
        applySalaryTypeSelection()
    }
    
    override func setupActions() {
        monthlyButton.addTarget(self, action: #selector(monthlyChipTapped), for: .touchUpInside)
        annualButton.addTarget(self, action: #selector(annualChipTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc private func monthlyChipTapped() {
        selectedSalaryType = .monthly
    }
    
    @objc private func annualChipTapped() {
        selectedSalaryType = .annual
    }
    
    @objc private func nextButtonTapped() {
        onNext()
    }
    
    @objc private func backgroundTapped() {
        view.endEditing(true)
    }
}


// MARK: - UI Configuration

private extension OnboardingSalaryViewController {
    func setupHierarchy() {
        view.addSubViews([titleLabel, subTitleLabel, salaryTypeLabel, optionStack])
        optionStack.addArrangedSubViews([monthlyButton, annualButton])
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(AppSpacing.screenHorizontal)
        }
        
        subTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(AppSpacing.screenHorizontal)
        }
        
        salaryTypeLabel.snp.makeConstraints { make in
            make.top.equalTo(subTitleLabel.snp.bottom).offset(32)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(AppSpacing.screenHorizontal)
        }
        
        optionStack.snp.makeConstraints { make in
            make.top.equalTo(salaryTypeLabel.snp.bottom).offset(8)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(AppSpacing.screenHorizontal)
        }
    }
}

// MARK: - Private Methods

private extension OnboardingSalaryViewController {
    func applySalaryTypeSelection() {
        monthlyButton.isSelected = (selectedSalaryType == .monthly)
        annualButton.isSelected = (selectedSalaryType == .annual)
    }
}
