//
//  CustomAlertViewController.swift
//  Moa
//
//  Created by mirim on 2/23/26.
//

import UIKit
import SnapKit

// MARK: - AlertAction

struct AlertAction {
    let title: String
    let style: Style
    let handler: (() -> Void)?
    
    enum Style {
        case primary, destructive, cancel
        
        var titleColor: UIColor {
            switch self {
            case .primary:     return .systemBlue
            case .destructive: return .systemRed
            case .cancel:      return .secondaryLabel
            }
        }
        
        var font: UIFont {
            switch self {
            case .primary:     return .systemFont(ofSize: 16, weight: .bold)
            case .destructive: return .systemFont(ofSize: 16, weight: .medium)
            case .cancel:      return .systemFont(ofSize: 16, weight: .regular)
            }
        }
    }
}

// MARK: - CustomAlertViewController

final class CustomAlertViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let dimView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        return view
    }()
    
    private let alertContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let labelStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .center
        return stack
    }()
    
    private let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        return view
    }()
    
    private let buttonStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        return stack
    }()
    
    private let contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        return stack
    }()
    
    // MARK: - Properties
    
    private let alertTitle: String?
    private let alertMessage: String?
    private let actions: [AlertAction]
    
    // MARK: - Init
    
    init(title: String?, message: String?, actions: [AlertAction]) {
        self.alertTitle = title
        self.alertMessage = message
        self.actions = actions
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
        setupActions()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.addSubview(dimView)
        view.addSubview(alertContainerView)
        alertContainerView.addSubview(contentStackView)
        
        // 레이블 구성
        if let title = alertTitle { titleLabel.text = title }
        if let message = alertMessage { messageLabel.text = message }
        labelStackView.addArrangedSubview(titleLabel)
        if alertMessage != nil { labelStackView.addArrangedSubview(messageLabel) }
        
        // 레이블 래퍼
        let labelWrapper = UIView()
        labelWrapper.addSubview(labelStackView)
        labelStackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(24)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        contentStackView.addArrangedSubview(labelWrapper)
        contentStackView.addArrangedSubview(dividerView)
        contentStackView.addArrangedSubview(buttonStackView)
        
        // 제약
        dimView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        alertContainerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(280)
        }
        
        contentStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        dividerView.snp.makeConstraints { make in
            make.height.equalTo(0.5)
        }
        
        buttonStackView.snp.makeConstraints { make in
            make.height.equalTo(52)
        }
    }
    
    private func setupActions() {
        actions.enumerated().forEach { index, action in
            if index > 0 {
                let verticalDivider = UIView()
                verticalDivider.backgroundColor = .separator
                buttonStackView.addArrangedSubview(verticalDivider)
                verticalDivider.snp.makeConstraints { make in
                    make.width.equalTo(0.5)
                }
            }
            
            let button = UIButton(type: .system)
            button.setTitle(action.title, for: .normal)
            button.setTitleColor(action.style.titleColor, for: .normal)
            button.titleLabel?.font = action.style.font
            button.tag = index
            button.addTarget(self, action: #selector(actionButtonTapped(_:)), for: .touchUpInside)
            buttonStackView.addArrangedSubview(button)
        }
    }
    
    @objc private func actionButtonTapped(_ sender: UIButton) {
        dismiss(animated: true) { [weak self] in
            self?.actions[sender.tag].handler?()
        }
    }
}
