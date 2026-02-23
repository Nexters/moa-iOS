//
//  CustomAlertViewController.swift
//  Moa
//
//  Created by mirim on 2/23/26.
//

import UIKit
import SnapKit

final class CustomAlertViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let dimView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        return view
    }()
    
    private let alertContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColor.Container.secondary
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    private let titleLabel: StyledLabel = {
        let label = StyledLabel()
        label.setStyle(.init(
            typography: AppTypography.t3_700,
            color: AppColor.IconAndText.highEmphasis
        ))
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let subtitleLabel: StyledLabel = {
        let label = StyledLabel()
        label.setStyle(.init(
            typography: AppTypography.b2_400,
            color: AppColor.IconAndText.mediumEmphasis
        ))
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let labelStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .center
        return stack
    }()
    
    private let buttonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        return stack
    }()
    
    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        return stack
    }()
    
    // MARK: - Properties
    
    private let alertTitle: String
    private let alertSubtitle: String?
    private let leftButtonTitle: String?
    private let rightButtonTitle: String
    private let onLeftButtonTapped: (() -> Void)?
    private let onRightButtonTapped: (() -> Void)?
    
    // MARK: - Init
    
    init(
        title: String,
        subtitle: String? = nil,
        leftButtonTitle: String? = nil,
        rightButtonTitle: String,
        onLeftButtonTapped: (() -> Void)? = nil,
        onRightButtonTapped: (() -> Void)? = nil
    ) {
        self.alertTitle = title
        self.alertSubtitle = subtitle
        self.leftButtonTitle = leftButtonTitle
        self.rightButtonTitle = rightButtonTitle
        self.onLeftButtonTapped = onLeftButtonTapped
        self.onRightButtonTapped = onRightButtonTapped
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.addSubview(dimView)
        view.addSubview(alertContainerView)
        alertContainerView.addSubview(contentStack)
        
        // 타이틀
        titleLabel.setText(alertTitle)
        labelStack.addArrangedSubview(titleLabel)
        
        // 서브타이틀 (옵셔널)
        if let subtitle = alertSubtitle {
            subtitleLabel.setText(subtitle)
            labelStack.addArrangedSubview(subtitleLabel)
        }
        
        // 버튼
        if let leftTitle = leftButtonTitle {
            buttonStack.addArrangedSubview(makeButton(title: leftTitle, style: .cancel))
        }
        buttonStack.addArrangedSubview(makeButton(title: rightButtonTitle, style: .confirm))
        
        contentStack.addArrangedSubViews([labelStack, buttonStack])
        
        dimView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        alertContainerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(38)
        }
        
        contentStack.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(24)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(18)
        }
        
        buttonStack.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(56)
        }
    }
    
    private enum ButtonStyle {
        case cancel, confirm
        
        var backgroundColor: UIColor {
            switch self {
            case .cancel:  return AppColor.Btn.Tertiary.enable
            case .confirm: return AppColor.Btn.Primary.enable
            }
        }
        
        var titleColor: UIColor {
            switch self {
            case .cancel:  return AppColor.IconAndText.highEmphasisReverse
            case .confirm: return AppColor.IconAndText.highEmphasisReverse
            }
        }
    }
    
    private func makeButton(title: String, style: ButtonStyle) -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = style.backgroundColor
        button.layer.cornerRadius = 28
        button.clipsToBounds = true
        
        var config = UIButton.Configuration.plain()
        var attributedTitle = AttributedString(title)
        attributedTitle.font = AppTypography.b1_600.font()
        attributedTitle.foregroundColor = style.titleColor
        config.attributedTitle = attributedTitle
        button.configuration = config
        
        switch style {
        case .cancel:
            button.addTarget(self, action: #selector(leftButtonTapped), for: .touchUpInside)
        case .confirm:
            button.addTarget(self, action: #selector(rightButtonTapped), for: .touchUpInside)
        }
        
        return button
    }
    
    // MARK: - Actions
    
    @objc private func leftButtonTapped() {
        dismiss(animated: true) { [weak self] in
            self?.onLeftButtonTapped?()
        }
    }
    
    @objc private func rightButtonTapped() {
        dismiss(animated: true) { [weak self] in
            self?.onRightButtonTapped?()
        }
    }
}

// MARK: - AlertManager

final class AlertManager {
    
    static func show(
        title: String,
        subtitle: String? = nil,
        leftButtonTitle: String? = nil,
        rightButtonTitle: String,
        onLeftButtonTapped: (() -> Void)? = nil,
        onRightButtonTapped: (() -> Void)? = nil
    ) {
        guard let topVC = topViewController() else { return }
        
        let alert = CustomAlertViewController(
            title: title,
            subtitle: subtitle,
            leftButtonTitle: leftButtonTitle,
            rightButtonTitle: rightButtonTitle,
            onLeftButtonTapped: onLeftButtonTapped,
            onRightButtonTapped: onRightButtonTapped
        )
        
        topVC.present(alert, animated: true)
    }
    
    private static func topViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }),
              let window = windowScene.windows.first(where: { $0.isKeyWindow })
        else { return nil }
        
        var topVC = window.rootViewController
        while let presented = topVC?.presentedViewController {
            topVC = presented
        }
        return topVC
    }
}
