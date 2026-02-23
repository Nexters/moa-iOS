//
//  ToastView.swift
//  Moa
//
//  Created by mirim on 2/23/26.
//

import UIKit
import SnapKit

// MARK: - ToastView

final class ToastView: UIView {
    
    private let messageLabel: StyledLabel = {
        let label = StyledLabel()
        label.setStyle(.init(typography: AppTypography.b1_400, color: .white))
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    init(message: String) {
        super.init(frame: .zero)
        messageLabel.setText(message)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupUI() {
        backgroundColor = AppColor.Container.secondary
        layer.cornerRadius = 12
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(messageLabel)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        messageLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(12)
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }
}

// MARK: - ToastManager

final class ToastManager {
    
    static func show(message: String, duration: TimeInterval = 2.0) {
        guard let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }),
              let window = windowScene.windows.first(where: { $0.isKeyWindow })
        else { return }
        
        let toast = ToastView(message: message)
        window.addSubview(toast)
        
        toast.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(window.safeAreaLayoutGuide).inset(32)
            make.leading.greaterThanOrEqualToSuperview().inset(44)
            make.trailing.lessThanOrEqualToSuperview().inset(44)
        }
        
        toast.alpha = 0
        UIView.animate(withDuration: 0.3) {
            toast.alpha = 1
        } completion: { _ in
            UIView.animate(withDuration: 0.3, delay: duration) {
                toast.alpha = 0
            } completion: { _ in
                toast.removeFromSuperview()
            }
        }
    }
}
