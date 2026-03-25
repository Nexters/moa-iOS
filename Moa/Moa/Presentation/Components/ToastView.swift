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
    
    private static var currentToast: ToastView?
    
    static func show(message: String, duration: TimeInterval = 2.0) {
        guard let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }),
              let window = windowScene.windows.first(where: { $0.isKeyWindow })
        else { return }
        
        let hasExisting = currentToast != nil
        currentToast?.layer.removeAllAnimations()
        currentToast?.removeFromSuperview()
        
        let toast = ToastView(message: message)
        currentToast = toast
        window.addSubview(toast)
        
        toast.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(window.safeAreaLayoutGuide).inset(32)
            make.leading.greaterThanOrEqualToSuperview().inset(44)
            make.trailing.lessThanOrEqualToSuperview().inset(44)
        }
        
        // 기존 토스트가 있었으면 fade in 없이 바로 표시
        toast.alpha = hasExisting ? 1 : 0
        let showCompletion: (Bool) -> Void = { _ in
            UIView.animate(withDuration: 0.3, delay: duration) {
                toast.alpha = 0
            } completion: { _ in
                toast.removeFromSuperview()
                if Self.currentToast === toast { Self.currentToast = nil }
            }
        }
        
        if hasExisting {
            showCompletion(true)
        } else {
            UIView.animate(
                withDuration: 0.3,
                animations: {
                    toast.alpha = 1
                },
                completion: showCompletion
            )
        }
    }
}
