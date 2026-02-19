//
//  TermsAgreementBottomSheetViewController.swift
//  Moa
//
//  Created by mirim on 2/13/26.
//

import UIKit
import SnapKit
import SafariServices

protocol TermsAgreementBottomSheetViewDelegate: AnyObject {
    func didTapConfirm(agreements: [String: Bool])
}

final class TermsAgreementBottomSheetViewController: UIViewController, BottomSheetPresentable {
    
    // MARK: - Constants
    
    private enum Constant {
        static let agreeAll = "전체 동의하기"
        static let required = "(필수) "
        static let optional = "(선택) "
        static let confirm = "확인"
    }
    
    // MARK: - Properties
    
    weak var delegate: TermsAgreementBottomSheetViewDelegate?
    private let viewModel: TermsAgreementBottomSheetViewModel
    
    // MARK: - UI
    
    private lazy var agreeAllButton: UIButton = {
        makeTermsAgreementButton(title: Constant.agreeAll, font: AppTypography.b1_600.font(), color: AppColor.IconAndText.highEmphasis)
    }()
    
    private let dividerView = DividerView(inset: 16)
    
    private let termsAgreementStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        return stack
    }()
    
    private let confirmButton: AppButton = {
        let btn = AppButton()
        btn.setTitle(Constant.confirm, for: .normal)
        btn.applyStyle(.primary())
        return btn
    }()
    
    // MARK: - Init
    
    init(viewModel: TermsAgreementBottomSheetViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupActions()
        viewModel.onStateChanged = { [weak self] in
            self?.updateUIFromViewModel()
        }
        updateUIFromViewModel()
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        view.addSubViews([agreeAllButton, dividerView, termsAgreementStackView, confirmButton])
        buildTermsAgreementRows()
        
        agreeAllButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
        }
        
        dividerView.snp.makeConstraints { make in
            make.top.equalTo(agreeAllButton.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
        }
        
        termsAgreementStackView.snp.makeConstraints { make in
            make.top.equalTo(dividerView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
            make.bottom.lessThanOrEqualToSuperview()
        }
        
        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(termsAgreementStackView.snp.bottom).offset(44)
            make.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
            make.bottom.equalToSuperview().offset(-24)
        }
    }
    
    private func setupActions() {
        agreeAllButton.addTarget(self, action: #selector(didTapAgreeAllButton), for: .touchUpInside)
        confirmButton.addTarget(self, action: #selector(didTapConfirm), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc private func didTapAgreeAllButton() {
        viewModel.setAll()
        updateUIFromViewModel()
    }
    
    @objc private func didToggleAgreement(_ sender: UIButton) {
        guard let code = sender.accessibilityIdentifier else { return }
        viewModel.toggle(code: code)
        updateUIFromViewModel()
    }
    
    @objc private func didTapTermDetail(_ sender: UIButton) {
        guard let code = sender.accessibilityIdentifier else { return }
        let urlString = viewModel.urlString(for: code)
        presentWeb(urlString: urlString)
    }
    
    @objc private func didTapConfirm() {
        delegate?.didTapConfirm(agreements: viewModel.agreementsByCode)
        dismissBottomSheet()
    }
    
    private func dismissBottomSheet() {
        (parent as? BottomSheetViewController)?.animateDismiss()
    }
    
    private func updateUIFromViewModel() {
        let agreeAllImage = UIImage(resource: viewModel.allAgreed ? .Icon.iconCheckCircleFill : .Icon.iconCheckCircle)
        
        agreeAllButton.configuration?.image = agreeAllImage
        confirmButton.isEnabled = viewModel.allRequiredAgreed
        
        for row in termsAgreementStackView.arrangedSubviews {
            for subview in row.subviews {
                guard let button = subview as? UIButton,
                      let code = button.accessibilityIdentifier,
                      button.configuration?.image != nil
                else { continue }
                
                let imageName: ImageResource = viewModel.agreed(for: code) ? .Icon.iconCheckCircleFill : .Icon.iconCheckCircle
                let image = UIImage(resource: imageName)
                button.configuration?.image = image
            }
        }
    }
    
    private func presentWeb(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        let safari = SFSafariViewController(url: url)
        safari.modalPresentationStyle = .fullScreen
        present(safari, animated: true)
    }
    
    private func buildTermsAgreementRows() {
        termsAgreementStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for term in viewModel.terms {
            let title = (term.required ? Constant.required : Constant.optional) + term.title
            let agreementButton = makeTermsAgreementButton(
                title: title,
                font: AppTypography.b1_400.font(),
                color: AppColor.IconAndText.highEmphasis
            )
            agreementButton.accessibilityIdentifier = term.code
            agreementButton.addTarget(self, action: #selector(didToggleAgreement(_:)), for: .touchUpInside)
            
            let chevronButton = makeChevronButton()
            chevronButton.accessibilityIdentifier = term.code
            chevronButton.addTarget(self, action: #selector(didTapTermDetail(_:)), for: .touchUpInside)
            
            let row = makeRowView(mainButton: agreementButton, chevronButton: chevronButton)
            termsAgreementStackView.addArrangedSubview(row)
        }
    }
}

// MARK: - UI Factories

private extension TermsAgreementBottomSheetViewController {
    
    func makeTermsAgreementButton(title: String, font: UIFont, color: UIColor) -> UIButton {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(resource: .Icon.iconCheckCircle)
        config.imagePlacement = .leading
        config.imagePadding = 8
        config.contentInsets = .init(top: 4, leading: 0, bottom: 4, trailing: 0)

        let btn = UIButton(configuration: config)
        btn.contentHorizontalAlignment = .leading
        btn.setAttributedTitle(
            NSAttributedString(
                string: title,
                attributes: [
                    .font: font,
                    .foregroundColor: color
                ]
            ),
            for: .normal
        )
        return btn
    }

    func makeChevronButton() -> UIButton {
        let btn = UIButton()
        btn.setImage(
            UIImage(resource: .Icon.iconChevronRight).withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        btn.tintColor = AppColor.IconAndText.disabled
        btn.contentHorizontalAlignment = .trailing
        return btn
    }
    
    func makeRowView(mainButton: UIButton, chevronButton: UIButton) -> UIView {
        let container = UIView()
        container.addSubViews([mainButton, chevronButton])
        
        chevronButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        mainButton.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalTo(chevronButton.snp.leading).offset(-8)
        }
        
        return container
    }
}
