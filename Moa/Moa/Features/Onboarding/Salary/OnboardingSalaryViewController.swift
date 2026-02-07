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
        static let amount = "금액"
        static let won = "원"
        static let next = "다음"
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
    
    private let salaryTypeView = SalaryTypeOptionView()
    
    /// "금액"
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.text = Constant.amount
        label.applyTextStyle(.init(
            typography: AppTypography.b2_500,
            color: AppColor.IconAndText.mediumEmphasis
        ))
        return label
    }()
    
    private let amountTextField: UITextField = {
        let tf = PaddingTextField()
        tf.textInsets = .init(top: 16, left: 20, bottom: 16, right: 0)
        tf.attributedPlaceholder = NSAttributedString(
            string: "0",
            attributes: [
                .foregroundColor: AppColor.IconAndText.disabled,
                .font: AppTypography.t2_700.font()
            ]
        )
        
        tf.clearButtonMode = .never
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.keyboardType = .numberPad
        
        tf.font = AppTypography.t2_700.font()
        tf.textColor = AppColor.IconAndText.highEmphasis
        
        tf.textAlignment = .left
        
        return tf
    }()
    
    private let currencyLabel: UILabel = {
        let label = UILabel()
        label.text = Constant.won
        label.applyTextStyle(.init(
            typography: AppTypography.b1_400,
            color: AppColor.IconAndText.mediumEmphasis
        ))
        return label
    }()
    
    private let amountTextFieldStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 10
        stack.distribution = .fill
        stack.backgroundColor = AppColor.Container.primary
        stack.layer.cornerRadius = 12
        return stack
    }()
    
    private let nextButton = AppButton()
    
    private lazy var commaFormatter = CommaNumberTextFieldFormatter(
        textField: amountTextField,
        maxDigits: SalaryType.monthly.maxDigits
    )
    
    // MARK: - Layout Components
    
    // 금액 "원" 우측 정렬 용도
    private let trailingSpacer: UIView = {
        let v = UIView()
        v.setContentHuggingPriority(.required, for: .horizontal)
        v.setContentCompressionResistancePriority(.required, for: .horizontal)
        return v
    }()
    
    // 키보드 위로 올라오는 CTA 영역 (다음)
    private let ctaContainer = UIView()
    
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
        setupButton()
        setupHierarchy()
        setupLayout()
        setupGesture()
    }
    
    override func setupActions() {
        amountTextField.delegate = self
        amountTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        
        salaryTypeView.onChange = { [weak self] type in
            guard let self else { return }
            self.viewModel.selectSalaryType(type)
            self.commaFormatter.updateMaxDigits(type.maxDigits)
            self.updateNextButtonState()
        }
        
        updateNextButtonState()
    }
    
    // MARK: - Actions
    
    @objc private func textDidChange() {
        commaFormatter.reformatNow()
        updateNextButtonState()
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
    func setupButton() {
        nextButton.setTitle(Constant.next, for: .normal)
        nextButton.applyStyle(.primary())
    }
    
    func setupHierarchy() {
        amountTextFieldStack.addArrangedSubViews([amountTextField, currencyLabel, trailingSpacer])
        ctaContainer.addSubview(nextButton)
        
        view.addSubViews([titleLabel, subTitleLabel, salaryTypeView, amountLabel, amountTextFieldStack, ctaContainer])
    }
    
    func setupLayout() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(AppSpacing.screenHorizontal)
        }
        
        subTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(AppSpacing.screenHorizontal)
        }
        
        salaryTypeView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(AppSpacing.screenHorizontal)
            make.top.equalTo(subTitleLabel.snp.bottom).offset(32)
        }
        
        amountLabel.snp.makeConstraints { make in
            make.top.equalTo(salaryTypeView.snp.bottom).offset(24)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(AppSpacing.screenHorizontal)
        }
        
        amountTextFieldStack.snp.makeConstraints { make in
            make.top.equalTo(amountLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
        }
        
        trailingSpacer.snp.makeConstraints { make in
            make.width.equalTo(20)
        }
        
        currencyLabel.setContentHuggingPriority(.required, for: .horizontal)
        currencyLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        amountTextField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        amountTextField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        ctaContainer.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(AppSpacing.screenHorizontal)
            make.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(-AppSpacing.ctaBottom)
        }
        
        nextButton.snp.makeConstraints { make in
            make.top.bottom.equalTo(ctaContainer)
            make.leading.trailing.equalTo(ctaContainer)
            make.height.greaterThanOrEqualTo(64)
        }
    }
}

// MARK: - Private Methods

private extension OnboardingSalaryViewController {
    func updateNextButtonState() {
        let digits = (amountTextField.text ?? "").filter(\.isNumber)
        let amount = Int(digits) ?? 0
        
        nextButton.isEnabled = amount > 0
    }
    
    func setupGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
}

// MARK: - UITextFieldDelegate

extension OnboardingSalaryViewController: UITextFieldDelegate {
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersInRanges ranges: [NSValue],
        replacementString string: String
    ) -> Bool {
        if textField.markedTextRange != nil { return true }
        if string.isEmpty { return true }
        guard string.allSatisfy(\.isNumber) else { return false }
        
        let currentDigitsCount = (textField.text ?? "").filter(\.isNumber).count
        let addingDigitsCount = string.filter(\.isNumber).count
        let limit = viewModel.selectedSalaryType.maxDigits
        
        return (currentDigitsCount + addingDigitsCount) <= limit
    }
}
