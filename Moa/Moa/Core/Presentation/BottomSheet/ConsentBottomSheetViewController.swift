//
//  ConsentBottomSheetViewController.swift
//  Moa
//
//  Created by mirim on 2/13/26.
//

import UIKit
import SnapKit

protocol ConsentBottomSheetViewDelegate: AnyObject {
    func didTapConfirm()
}

final class ConsentBottomSheetViewController: UIViewController, BottomSheetPresentable {
    
    // MARK: - Constants
    
    private enum Constant {
        static let agreeAll = "전체 동의하기"
        static let required = "(필수) "
        static let optional = "(선택) "
        static let confirm = "확인"
    }
    
    // MARK: - Properties
    
    weak var delegate: ConsentBottomSheetViewDelegate?
    private let viewModel = ConsentBottomSheetViewModel()

    
    // MARK: - UI
    
    private lazy var agreeAllButton: UIButton = {
        makeConsentButton(title: Constant.agreeAll, font: AppTypography.b1_600.font(), color: AppColor.IconAndText.highEmphasis)
    }()
    
    private let dividerView = DividerView(inset: 16)
    
    private let consentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        return stack
    }()
    
    private lazy var usageTermConsentButton: UIButton = {
        makeConsentButton(
            title: Constant.required + Consent.usageTerm.description,
            font: AppTypography.b1_400.font(),
            color: AppColor.IconAndText.highEmphasis
        )
    }()
    
    private lazy var personalInfoConsentButton: UIButton = {
        makeConsentButton(
            title: Constant.required + Consent.personalInfo.description,
            font: AppTypography.b1_400.font(),
            color: AppColor.IconAndText.highEmphasis
        )
    }()
    
    private lazy var marketingConsentButton: UIButton = {
        makeConsentButton(
            title: Constant.optional + Consent.marketing.description,
            font: AppTypography.b1_400.font(),
            color: AppColor.IconAndText.highEmphasis
        )
    }()
    
    private lazy var usageTermChevronButton: UIButton = { makeChevronButton() }()
    private lazy var personalInfoChevronButton: UIButton = { makeChevronButton() }()
    private lazy var marketingChevronButton: UIButton = { makeChevronButton() }()
    
    private lazy var usageTermRow: UIView = makeRowView(
        mainButton: usageTermConsentButton,
        chevronButton: usageTermChevronButton
    )
    private lazy var personalInfoRow: UIView = makeRowView(
        mainButton: personalInfoConsentButton,
        chevronButton: personalInfoChevronButton
    )
    private lazy var marketingRow: UIView = makeRowView(
        mainButton: marketingConsentButton,
        chevronButton: marketingChevronButton
    )
    
    private let confirmButton: AppButton = {
        let btn = AppButton()
        btn.setTitle(Constant.confirm, for: .normal)
        btn.applyStyle(.primary())
        return btn
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupActions()
        updateUIFromViewModel()
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        view.addSubViews([agreeAllButton, dividerView, consentStackView, confirmButton])
        consentStackView.addArrangedSubViews([usageTermRow, personalInfoRow, marketingRow])
        
        agreeAllButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
        }
        
        dividerView.snp.makeConstraints { make in
            make.top.equalTo(agreeAllButton.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
        }
        
        consentStackView.snp.makeConstraints { make in
            make.top.equalTo(dividerView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
            make.bottom.lessThanOrEqualToSuperview()
        }
        
        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(consentStackView.snp.bottom).offset(44)
            make.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
            make.bottom.equalToSuperview().offset(-24)
        }
    }
    
    private func setupActions() {
        agreeAllButton.addTarget(self, action: #selector(didTapAgreeAllButton), for: .touchUpInside)
        usageTermChevronButton.addTarget(self, action: #selector(didTapUsageTermDetail), for: .touchUpInside)
        personalInfoChevronButton.addTarget(self, action: #selector(didTapPersonalInfoDetail), for: .touchUpInside)
        marketingChevronButton.addTarget(self, action: #selector(didTapMarketingDetail), for: .touchUpInside)
        
        usageTermConsentButton.addTarget(self, action: #selector(didToggleUsageConsent), for: .touchUpInside)
        personalInfoConsentButton.addTarget(self, action: #selector(didTogglePersonalInfoConsent), for: .touchUpInside)
        marketingConsentButton.addTarget(self, action: #selector(didToggleMarketingConsent), for: .touchUpInside)
        
        confirmButton.addTarget(self, action: #selector(didTapConfirm), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc private func didTapUsageTermDetail() {
        // TODO: 웹뷰 띄우기
    }

    @objc private func didTapPersonalInfoDetail() {
        // TODO: 웹뷰 띄우기
    }

    @objc private func didTapMarketingDetail() {
        // TODO: 웹뷰 띄우기
    }
    
    @objc private func didTapAgreeAllButton() {
        viewModel.setAll()
        updateUIFromViewModel()
    }
    
    @objc private func didToggleUsageConsent() {
        viewModel.toggleUsageTerm()
        updateUIFromViewModel()
    }

    @objc private func didTogglePersonalInfoConsent() {
        viewModel.togglePersonalInfo()
        updateUIFromViewModel()
    }

    @objc private func didToggleMarketingConsent() {
        viewModel.toggleMarketing()
        updateUIFromViewModel()
    }
    
    @objc private func didTapConfirm() {
        delegate?.didTapConfirm()
        dismissBottomSheet()
    }
    
    private func dismissBottomSheet() {
        (parent as? BottomSheetViewController)?.animateDismiss()
    }
    
    private func updateUIFromViewModel() {
        let agreeAllImage = UIImage(resource: viewModel.allAgreed ? .Icon.iconCheckCircleFill : .Icon.iconCheckCircle)
        agreeAllButton.configuration?.image = agreeAllImage

        let usageImage = UIImage(resource: viewModel.usageTermAgreed ? .Icon.iconCheckCircleFill : .Icon.iconCheckCircle)
        usageTermConsentButton.configuration?.image = usageImage

        let personalImage = UIImage(resource: viewModel.personalInfoAgreed ? .Icon.iconCheckCircleFill : .Icon.iconCheckCircle)
        personalInfoConsentButton.configuration?.image = personalImage

        let marketingImage = UIImage(resource: viewModel.marketingAgreed ? .Icon.iconCheckCircleFill : .Icon.iconCheckCircle)
        marketingConsentButton.configuration?.image = marketingImage

        confirmButton.isEnabled = viewModel.allRequiredAgreed
    }
}

// MARK: - UI Factories

private extension ConsentBottomSheetViewController {
    
    func makeConsentButton(title: String, font: UIFont, color: UIColor) -> UIButton {
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
