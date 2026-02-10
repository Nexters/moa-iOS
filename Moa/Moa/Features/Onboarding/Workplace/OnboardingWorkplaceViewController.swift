//
//  OnboardingWorkplaceViewController.swift
//  Moa
//
//  Created by mirim on 2/1/26.
//

import UIKit
import SnapKit

final class OnboardingWorkplaceViewController: BaseViewController {
    // MARK: - Constants
    
    private enum Constant {
        static let workplace = "근무지"
        static let workplaceSuffix = "에서 일해요"
        static let workplacePlaceholder = "근무지를 입력해주세요"
        static let workplaceHint = "20자까지 입력할 수 있어요"
        static let next = "다음"
        static let workplaceMaxLength: Int = 20
        static let textViewMinHeight: CGFloat = 70
    }
    
    // MARK: - Dependencies
    
    private let viewModel: OnboardingWorkplaceViewModel
    private let onNext: (() -> Void)
    
    // MARK: - UI Components
    
    private let stackView: UIStackView = {
        let v = UIStackView()
        v.axis = .vertical
        v.spacing = 8
        v.alignment = .center
        v.distribution = .fill
        return v
    }()
    
    /// "근무지"
    private let titleLabel: UILabel = {
        let label = StyledLabel()
        label.setText(
            Constant.workplace,
            style: .init(
                typography: AppTypography.t1_700,
                color: AppColor.IconAndText.highEmphasis
            )
        )
        return label
    }()
    
    private let workplaceTextView: UITextView = {
        let tv = UITextView()
        tv.isScrollEnabled = false // 아래로 늘어나도록
        tv.textContainerInset = .init(top: 16, left: 20, bottom: 16, right: 20)
        tv.textContainer.lineFragmentPadding = 0
        
        tv.backgroundColor = AppColor.Container.primary
        tv.font = AppTypography.h3_700.font()
        tv.textColor = AppColor.IconAndText.green
        tv.layer.cornerRadius = 16
        
        tv.autocapitalizationType = .none
        tv.autocorrectionType = .no
        tv.returnKeyType = .done
        tv.textAlignment = .center
        return tv
    }()
    
    private let workplacePlaceholderLabel: UILabel = {
        let label = StyledLabel()
        label.setText(
            Constant.workplacePlaceholder,
            style: .init(
                typography: AppTypography.h3_700,
                color: AppColor.IconAndText.disabled
            )
        )
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    /// "에서 일해요"
    private let subtitleLabel: UILabel = {
        let label = StyledLabel()
        label.setText(
            Constant.workplaceSuffix,
            style: .init(
                typography: AppTypography.t1_700,
                color: AppColor.IconAndText.highEmphasis
            )
        )
        return label
    }()
    
    private let workplaceHintLabel: UILabel = {
        let label = StyledLabel()
        label.setText(
            Constant.workplaceHint,
            style: .init(
                typography: AppTypography.b2_500,
                color: AppColor.IconAndText.lowEmphasis
            )
        )
        label.isHidden = true
        return label
    }()
    
    private let nextButton = AppButton()
    
    // MARK: - Layout Components
    
    // 상하단 비율(1:2) 유지 용도
    private let spacerTop = UIView()
    private let spacerBottom = UIView()
    
    // 키보드 위로 올라오는 CTA 영역 (힌트 + 다음)
    private let ctaContainer = UIView()
    private let ctaStack: UIStackView = {
        let v = UIStackView()
        v.axis = .vertical
        v.spacing = 12
        v.alignment = .center
        return v
    }()
    
    // MARK: - Init
    
    init(
        viewModel: OnboardingWorkplaceViewModel,
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
        setupSpacers()
        setupHierarchy()
        setupLayout()
        setupGesture()
    }
    
    override func setupActions() {
        workplaceTextView.delegate = self
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        
        updateNextButtonState()
    }
    
    // MARK: - Actions
    
    @objc private func nextButtonTapped() {
        view.endEditing(true)
        onNext()
    }
    
    @objc private func backgroundTapped() {
        view.endEditing(true)
    }
}

// MARK: - UI Configuration

private extension OnboardingWorkplaceViewController {
    func setupButton() {
        nextButton.setTitle(Constant.next, for: .normal)
        nextButton.applyStyle(.primary())
    }
    
    func setupSpacers() {
        spacerTop.backgroundColor = .clear
        spacerBottom.backgroundColor = .clear
    }
    
    func setupHierarchy() {
        stackView.addArrangedSubViews([
            spacerTop,
            titleLabel,
            workplaceTextView,
            subtitleLabel,
            spacerBottom
        ])
        workplaceTextView.addSubview(workplacePlaceholderLabel)
        
        ctaContainer.addSubview(ctaStack)
        ctaStack.addArrangedSubViews([workplaceHintLabel, nextButton])
        
        view.addSubViews([stackView, ctaContainer])
    }
    
    func setupLayout() {
        spacerTop.snp.makeConstraints { make in
            make.height.equalTo(spacerBottom.snp.height).multipliedBy(0.5) // top = bottom * 1/2
        }
        
        workplaceTextView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(stackView).inset(AppSpacing.screenHorizontal)
        }
        
        workplacePlaceholderLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().inset(20)
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(AppSpacing.screenHorizontal)
            make.bottom.equalTo(ctaContainer.snp.top)
        }
        
        ctaStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        ctaContainer.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(AppSpacing.screenHorizontal)
            make.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(-AppSpacing.ctaBottom)
        }
        
        nextButton.snp.makeConstraints { make in
            make.leading.trailing.equalTo(ctaContainer)
        }
    }
}

// MARK: - UITextViewDelegate

extension OnboardingWorkplaceViewController: UITextViewDelegate {
    func textView(
        _ textView: UITextView,
        shouldChangeTextIn range: NSRange,
        replacementText text: String
    ) -> Bool {
        if let marked = textView.markedTextRange,
           textView.position(from: marked.start, offset: 0) != nil {
            return true
        }
        
        let current = textView.text ?? ""
        guard let r = Range(range, in: current) else { return false }
        
        let next = current.replacingCharacters(in: r, with: text)
        return next.count <= Constant.workplaceMaxLength
    }
    
    func textViewDidChange(_ textView: UITextView) {
        updatePlaceholderVisibility() // placeholder 토글
        updateNextButtonState() // [다음] 버튼 활성화
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        workplaceHintLabel.isHidden = false
        updatePlaceholderVisibility()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        workplaceHintLabel.isHidden = true
        updatePlaceholderVisibility()
    }
}

// MARK: - Private Methods

private extension OnboardingWorkplaceViewController {
    var workplaceText: String {
        workplaceTextView.text ?? ""
    }
    
    var isWorkplaceValid: Bool {
        !workplaceText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func updatePlaceholderVisibility() {
        workplacePlaceholderLabel.isHidden = !workplaceText.isEmpty
    }
    
    func updateNextButtonState() {
        nextButton.isEnabled = isWorkplaceValid
    }
    
    func setupGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
}
