//
//  NicknameEditViewController.swift
//  Moa
//
//  Created by mirim on 2/19/26.
//

import UIKit
import SnapKit

final class NicknameEditViewController: BaseViewController {
    
    // MARK: - Constants
    
    private enum Constant {
        static let nicknameEdit = "닉네임 수정"
        static let nickname = "닉네임"
        static let nicknameSuffix = "로 수정할게요"
        static let nicknamePlaceholder = "닉네임을 입력해주세요"
        static let nicknameHint = "10자까지 입력할 수 있어요"
        static let randomChange = "랜덤변경"
        static let complete = "완료"
        static let nicknameMaxLength: Int = 10
    }
    
    // MARK: - Dependencies
    
    private let viewModel: NicknameEditViewModel
    private weak var router: AppRouting?
    
    // MARK: - UI Components
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .center
        stack.distribution = .fill
        return stack
    }()
    
    /// "닉네임"
    private let titleLabel: UILabel = {
        let label = StyledLabel()
        label.setText(
            Constant.nickname,
            style: .init(
                typography: AppTypography.t1_700,
                color: AppColor.IconAndText.highEmphasis
            )
        )
        return label
    }()
    
    private let nicknameTextField: UITextField = {
        let tf = PaddingTextField()
        tf.textInsets = .init(top: 16, left: 20, bottom: 16, right: 20)
        tf.attributedPlaceholder = NSAttributedString(
            string: Constant.nicknamePlaceholder,
            attributes: [
                .foregroundColor: AppColor.IconAndText.disabled,
                .font: AppTypography.h3_700.font()
            ]
        )
        
        tf.clearButtonMode = .never
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.returnKeyType = .done
        
        tf.backgroundColor = AppColor.Container.primary
        tf.font = AppTypography.h3_700.font()
        tf.textColor = AppColor.IconAndText.green
        
        tf.layer.cornerRadius = 16
        tf.textAlignment = .center
        return tf
    }()
    
    /// "로 시작할래요"
    private let subtitleLabel: UILabel = {
        let label = StyledLabel()
        label.setText(
            Constant.nicknameSuffix,
            style: .init(
                typography: AppTypography.t1_700,
                color: AppColor.IconAndText.highEmphasis
            )
        )
        return label
    }()
    
    private let randomChangeButton: UIButton = {
        let btn = UIButton()
        var config = UIButton.Configuration.plain()
        config.image = UIImage(resource: .Icon.iconRefresh).withRenderingMode(.alwaysOriginal)
        
        var title = AttributedString(Constant.randomChange)
        title.font = AppTypography.b2_500.font()
        title.foregroundColor = AppColor.IconAndText.highEmphasis
        config.attributedTitle = title
        
        config.imagePlacement = .leading
        config.imagePadding = 4
        config.background.backgroundColor = AppColor.Container.secondary
        config.background.cornerRadius = 8
        config.contentInsets = .init(top: 8, leading: 12, bottom: 8, trailing: 12)
        
        btn.configuration = config
        return btn
    }()
    
    private let nicknameHintLabel: UILabel = {
        let label = StyledLabel()
        label.setText(
            Constant.nicknameHint,
            style: .init(
                typography: AppTypography.b2_500,
                color: AppColor.IconAndText.lowEmphasis
            )
        )
        label.isHidden = true
        return label
    }()
    
    private let completeButton: AppButton = {
        let btn = AppButton()
        btn.setTitle(Constant.complete, for: .normal)
        btn.applyStyle(.primary())
        return btn
    }()
    
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
    
    init(viewModel: NicknameEditViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    override func setupUI() {
        replaceSystemBackButtonWithAppBackButton()
        setupNavigationTitle(as: Constant.nicknameEdit)
        
        setupSpacers()
        setupHierarchy()
        setupLayout()
        setupGesture()
    }
    
    override func setupActions() {
        nicknameTextField.delegate = self
        nicknameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        randomChangeButton.addTarget(self, action: #selector(randomChangeButtonTapped), for: .touchUpInside)
        completeButton.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
        
        if let initialNickname = viewModel.currentNickname {
            nicknameTextField.text = initialNickname
        } else {
            nicknameTextField.text = viewModel.makeRandomNickname()
        }
        
        updateCompleteButtonState()
    }
    
    // MARK: - Actions
    
    @objc private func textDidChange() {
        updateCompleteButtonState()
    }
    
    @objc private func randomChangeButtonTapped() {
        nicknameTextField.text = viewModel.makeRandomNickname()
        updateCompleteButtonState()
    }
    
    @objc private func completeButtonTapped() {
        viewModel.updateNickname(to: nicknameTextField.text)
    }
    
    @objc private func backgroundTapped() {
        view.endEditing(true)
    }
    
    override func bind() {
        bindOutput(viewModel.outputs) { [weak self] output in
            switch output {
            case .nicknameEdited:
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
}

// MARK: - UI Configuration

private extension NicknameEditViewController {
    func setupSpacers() {
        spacerTop.backgroundColor = .clear
        spacerBottom.backgroundColor = .clear
    }
    
    func setupHierarchy() {
        stackView.addArrangedSubViews([
            spacerTop,
            titleLabel,
            nicknameTextField,
            subtitleLabel,
            randomChangeButton,
            spacerBottom
        ])
        stackView.setCustomSpacing(32, after: subtitleLabel)
        
        ctaContainer.addSubview(ctaStack)
        ctaStack.addArrangedSubViews([nicknameHintLabel, completeButton])
        
        view.addSubViews([stackView, ctaContainer])
    }
    
    func setupLayout() {
        spacerTop.snp.makeConstraints { make in
            make.height.equalTo(spacerBottom.snp.height).multipliedBy(0.5) // top = bottom * 1/2
        }
        
        nicknameTextField.snp.makeConstraints { make in
            make.leading.trailing.equalTo(stackView).inset(AppSpacing.screenHorizontal)
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(AppSpacing.screenHorizontal)
            make.bottom.equalTo(completeButton.snp.top)
        }
        
        ctaStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        ctaContainer.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(AppSpacing.screenHorizontal)
            make.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(-AppSpacing.ctaBottom)
        }
        
        completeButton.snp.makeConstraints { make in
            make.leading.trailing.equalTo(ctaContainer)
        }
    }
}

// MARK: - UITextFieldDelegate

extension NicknameEditViewController: UITextFieldDelegate {
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        if let marked = textField.markedTextRange,
           textField.position(from: marked.start, offset: 0) != nil {
            return true
        }
        
        let current = textField.text ?? ""
        guard let textRange = Range(range, in: current) else { return false }
        let next = current.replacingCharacters(in: textRange, with: string)
        
        let sanitized = TextSanitizer.sanitizeKoreanEnglishNoSpaces(next)
        
        if sanitized != next {
            textField.text = String(sanitized.prefix(Constant.nicknameMaxLength))
            return false
        }
        
        return sanitized.count <= Constant.nicknameMaxLength
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        nicknameHintLabel.isHidden = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        nicknameHintLabel.isHidden = true
    }
}

// MARK: - Private Methods

private extension NicknameEditViewController {
    func updateCompleteButtonState() {
        let text = nicknameTextField.text ?? ""
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        completeButton.isEnabled = !trimmed.isEmpty
    }
    
    func setupGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
}
