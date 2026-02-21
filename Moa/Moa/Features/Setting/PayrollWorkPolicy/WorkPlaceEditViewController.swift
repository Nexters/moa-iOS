//
//  WorkPlaceEditViewController.swift
//  Moa
//
//  Created by mirim on 2/22/26.
//

import UIKit
import SnapKit

final class WorkPlaceEditViewController: BaseViewController {
    // MARK: - Constants
    
    private enum Constant {
        static let firstLabelText = "저는"
        static let workplaceSuffix = "에서 일해요"
        static let workplacePlaceholder = "회사명을 입력해주세요"
        static let workplaceHint = "20자까지 입력할 수 있어요"
        static let complete = "완료"
        static let companyName = "회사명"
        static let workplaceMaxLength: Int = 20
        static let textViewMinHeight: CGFloat = 70
    }
    
    // MARK: - Dependencies
    
    private let viewModel: WorkPlaceEditViewModel
    
    // MARK: - UI
    
    private let stackView: UIStackView = {
        let v = UIStackView()
        v.axis = .vertical
        v.spacing = 8
        v.alignment = .center
        v.distribution = .fill
        return v
    }()
    
    /// "저는"
    private let titleLabel: StyledLabel = {
        let label = StyledLabel()
        label.setText(
            Constant.firstLabelText,
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
        
        tv.backgroundColor = AppColor.Background.secondary
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
        let label = UILabel()
        label.text = Constant.workplacePlaceholder
        label.textColor = AppColor.IconAndText.disabled
        label.font = AppTypography.h3_700.font()
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    /// "에서 일해요"
    private let subtitleLabel: StyledLabel = {
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
    
    private let workplaceHintLabel: StyledLabel = {
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
    
    private let completeButton = AppButton()
    
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
    
    init(
        viewModel: WorkPlaceEditViewModel
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
        setupNavigationTitle(as: Constant.companyName)
        configureViews()
        buildHierarchy()
        setupLayout()
        setupGesture()
    }
    
    override func setupActions() {
        workplaceTextView.delegate = self
        completeButton.addTarget(self, action: #selector(didTapComplete), for: .touchUpInside)
        
        updateCompleteButtonState()
    }
    
    // MARK: - Actions
    
    @objc private func didTapComplete() {
        Task {
            do {
                try await viewModel.updateWorkplace(to: workplaceTextView.text)
                navigationController?.popViewController(animated: true)
            } catch {
                // TODO: 에러 처리
            }
        }
    }
    
    @objc private func didTapBackground() {
        view.endEditing(true)
    }
}

private extension WorkPlaceEditViewController {
    func configureViews() {
        workplaceTextView.text = viewModel.currentWorkplace ?? ""
        updatePlaceholderVisibility()
        
        completeButton.setTitle(Constant.complete, for: .normal)
        completeButton.applyStyle(.primary())
        
        spacerTop.backgroundColor = .clear
        spacerBottom.backgroundColor = .clear
    }
    
    func buildHierarchy() {
        stackView.addArrangedSubViews([
            spacerTop,
            titleLabel,
            workplaceTextView,
            subtitleLabel,
            spacerBottom
        ])
        
        workplaceTextView.addSubview(workplacePlaceholderLabel)
        
        view.addSubViews([stackView, ctaContainer])
        
        ctaContainer.addSubview(ctaStack)
        ctaStack.addArrangedSubViews([workplaceHintLabel, completeButton])
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
            make.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(-24)
        }
        
        completeButton.snp.makeConstraints { make in
            make.leading.trailing.equalTo(ctaContainer)
        }
    }
    
    func setupGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapBackground))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
}

extension WorkPlaceEditViewController: UITextViewDelegate {
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
        updateCompleteButtonState() // [완료] 버튼 활성화
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

// MARK: - Helpers
private extension WorkPlaceEditViewController {
    func updatePlaceholderVisibility() {
        let text = workplaceTextView.text ?? ""
        workplacePlaceholderLabel.isHidden = !text.isEmpty
    }
    
    func updateCompleteButtonState() {
        let text = workplaceTextView.text ?? ""
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        completeButton.isEnabled = !trimmed.isEmpty
    }
}
