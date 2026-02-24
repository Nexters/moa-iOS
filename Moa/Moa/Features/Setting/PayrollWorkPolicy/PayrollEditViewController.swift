//
//  PayrollEditViewController.swift
//  Moa
//
//  Created by mirim on 2/22/26.
//

import UIKit
import SnapKit

final class PayrollEditViewController: BaseViewController {
    
    // MARK: - Constants
    
    private enum Constant {
        static let title = "얼마씩 받고 있나요?"
        static let subtitle = "입력한 정보를 바탕으로 실시간 급여가 계산되며,\n급여 정보는 누구에게도 공개되지 않아요."
        static let amount = "금액"
        static let won = "원"
        static let complete = "완료"
        static let salary = "급여"
    }
    
    // MARK: - Dependencies
    
    private let viewModel: PayrollEditViewModel
    
    // MARK: - UI Components
    
    /// "얼마씩 받고 있나요?"
    private let titleLabel: UILabel = {
        let label = StyledLabel()
        label.setText(
            Constant.title,
            style: .init(
                typography: AppTypography.t1_700,
                color: AppColor.IconAndText.highEmphasis
            )
        )
        return label
    }()
    
    private let subTitleLabel: UILabel = {
        let label = StyledLabel()
        label.setText(
            Constant.subtitle,
            style: .init(
                typography: AppTypography.b2_400,
                color: AppColor.IconAndText.mediumEmphasis
            )
        )
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    private let salaryTypeView = SalaryTypeOptionView()
    
    /// "금액"
    private let amountLabel: UILabel = {
        let label = StyledLabel()
        label.setText(
            Constant.amount,
            style: .init(
                typography: AppTypography.b2_500,
                color: AppColor.IconAndText.mediumEmphasis
            )
        )
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
        let label = StyledLabel()
        label.setText(
            Constant.won,
            style: .init(
                typography: AppTypography.b1_400,
                color: AppColor.IconAndText.mediumEmphasis
            )
        )
        return label
    }()
    
    private let formattedAmountLabel: StyledLabel = {
        let label = StyledLabel()
        label.setStyle(
            .init(
                typography: AppTypography.b2_500,
                color: AppColor.IconAndText.green
            )
        )
        return label
    }()
    
    private let koreanAmountLabel: StyledLabel = {
        let label = StyledLabel()
        label.setStyle(
            .init(
                typography: AppTypography.b2_500,
                color: AppColor.IconAndText.green
            )
        )
        label.numberOfLines = 1
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
    
    private let completeButton = AppButton()
    
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
        viewModel: PayrollEditViewModel
    ) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    override func setupUI() {
        replaceSystemBackButtonWithAppBackButton()
        setupNavigationTitle(as: Constant.salary)
        setupButton()
        setupHierarchy()
        setupLayout()
        setupGesture()
    }
    
    override func setupActions() {
        amountTextField.delegate = self
        amountTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        
        completeButton.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
        
        salaryTypeView.setSelected(viewModel.selectedSalaryType, notify: false)
        commaFormatter.updateMaxDigits(viewModel.selectedSalaryType.maxDigits)
        
        salaryTypeView.onChange = { [weak self] type in
            guard let self else { return }
            self.viewModel.selectSalaryType(type)
            self.commaFormatter.updateMaxDigits(type.maxDigits)
            self.updateNextButtonState()
        }
        
        updateNextButtonState()
        
        let initialDigits = (amountTextField.text ?? "").filter(\.isNumber)
        let initialValue = Int(initialDigits) ?? 0
        koreanAmountLabel.text = AppNumberFormatter.koreanCurrencyText(for: initialValue)
        
        if let amount = viewModel.amount {
            let formatted = NumberFormatter.localizedString(from: NSNumber(value: amount), number: .decimal)
            amountTextField.text = formatted
            koreanAmountLabel.setText(AppNumberFormatter.koreanCurrencyText(for: amount))
            updateNextButtonState()
        }
    }
    
    // MARK: - Actions
    
    @objc private func textDidChange() {
        commaFormatter.reformatNow()
        updateNextButtonState()
        let digits = (amountTextField.text ?? "").filter(\.isNumber)
        let value = Int(digits) ?? 0
        koreanAmountLabel.setText(AppNumberFormatter.koreanCurrencyText(for: value))
        viewModel.updateAmount(fromTextFieldText: amountTextField.text)
    }
    
    @objc private func completeButtonTapped() {
        Task { @MainActor in
            do {
                try await viewModel.updatePayroll()
                self.navigationController?.popViewController(animated: true)
            } catch {
                ToastManager.show(message: "급여 수정에 실패했습니다.")
            }
        }
    }
    
    @objc private func backgroundTapped() {
        view.endEditing(true)
    }
}

// MARK: - UI Configuration

private extension PayrollEditViewController {
    func setupButton() {
        completeButton.setTitle(Constant.complete, for: .normal)
        completeButton.applyStyle(.primary())
    }
    
    func setupHierarchy() {
        amountTextFieldStack.addArrangedSubViews([amountTextField, currencyLabel, trailingSpacer])
        ctaContainer.addSubview(completeButton)
        
        view.addSubViews([titleLabel, subTitleLabel, salaryTypeView, amountLabel, amountTextFieldStack, koreanAmountLabel, ctaContainer])
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
        
        koreanAmountLabel.snp.makeConstraints { make in
            make.top.equalTo(amountTextFieldStack.snp.bottom).offset(8)
            make.trailing.equalTo(amountTextFieldStack)
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
        
        completeButton.snp.makeConstraints { make in
            make.top.bottom.equalTo(ctaContainer)
            make.leading.trailing.equalTo(ctaContainer)
            make.height.greaterThanOrEqualTo(64)
        }
    }
}

// MARK: - Private Methods

private extension PayrollEditViewController {
    func updateNextButtonState() {
        let digits = (amountTextField.text ?? "").filter(\.isNumber)
        let amount = Int(digits) ?? 0
        
        completeButton.isEnabled = amount > 0
    }
    
    func setupGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
}

// MARK: - UITextFieldDelegate

extension PayrollEditViewController: UITextFieldDelegate {
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
