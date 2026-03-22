//
//  OnboardingPayrollViewController.swift
//  Moa
//
//  Created by mirim on 2/3/26.
//

import UIKit
import SnapKit

final class OnboardingPayrollViewController: BaseViewController {
    
    // MARK: - Constants
    
    private enum Constant {
        static let title = "얼마씩 받고 있나요?"
        static let subtitle = "입력한 정보를 바탕으로 실시간 급여가 계산되며,\n급여 정보는 누구에게도 공개되지 않아요."
        static let amount = "금액"
        static let won = "원"
        static let next = "다음"
        static let lessThanMinAmountErrorMessage = "금액은 1만원 이상 입력해 주세요"
    }
    
    // MARK: - Dependencies
    
    private let viewModel: OnboardingPayrollViewModel
    private let onNext: (() -> Void)
    
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

    private let errorIconView: UIImageView = {
        let iv = UIImageView(image: UIImage(resource: .Icon.iconAttentionCircle))
        iv.contentMode = .scaleAspectFit
        iv.setContentHuggingPriority(.required, for: .horizontal)
        iv.setContentCompressionResistancePriority(.required, for: .horizontal)
        return iv
    }()

    private let errorLabel: StyledLabel = {
        let label = StyledLabel()
        label.setText(
            Constant.lessThanMinAmountErrorMessage,
            style: .init(
                typography: AppTypography.b2_500,
                color: AppColor.IconAndText.error
            )
        )
        return label
    }()

    private lazy var errorStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [errorIconView, errorLabel])
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .center
        stack.isHidden = true
        return stack
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
        viewModel: OnboardingPayrollViewModel,
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
    
    @objc private func nextButtonTapped() {
        Task { @MainActor in
            do {
                try await viewModel.updatePayroll()
                onNext()
            } catch {
                ToastManager.show(message: "급여정보 등록에 실패했습니다.")
            }
        }
    }
    
    @objc private func backgroundTapped() {
        view.endEditing(true)
    }
}

// MARK: - UI Configuration

private extension OnboardingPayrollViewController {
    func setupButton() {
        nextButton.setTitle(Constant.next, for: .normal)
        nextButton.applyStyle(.primary())
    }
    
    func setupHierarchy() {
        amountTextFieldStack.addArrangedSubViews([amountTextField, currencyLabel, trailingSpacer])
        ctaContainer.addSubview(nextButton)
        
        view.addSubViews([titleLabel, subTitleLabel, salaryTypeView, amountLabel, amountTextFieldStack, koreanAmountLabel, errorStackView, ctaContainer])
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

        errorStackView.snp.makeConstraints { make in
            make.top.equalTo(amountTextFieldStack.snp.bottom).offset(8)
            make.leading.equalTo(amountTextFieldStack)
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

private extension OnboardingPayrollViewController {
    func updateNextButtonState() {
        let digits = (amountTextField.text ?? "").filter(\.isNumber)
        let amount = Int(digits) ?? 0

        let hasError = amount > 0 && amount < 10_000
        errorStackView.isHidden = !hasError
        koreanAmountLabel.isHidden = hasError

        nextButton.isEnabled = amount > 0
    }
    
    func setupGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        tap.cancelsTouchesInView = false
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }
}

// MARK: - UITextFieldDelegate

extension OnboardingPayrollViewController: UITextFieldDelegate {
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

extension OnboardingPayrollViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return !nextButton.bounds.contains(touch.location(in: nextButton))
    }
}
