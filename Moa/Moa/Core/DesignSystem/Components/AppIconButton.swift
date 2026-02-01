//
//  AppIconButton.swift
//  Moa
//
//  Created by 정도현 on 2/1/26.
//

import UIKit
import SnapKit

/// Moa App 내부에서 사용되는 앱 아이콘 버튼입니다.
final class AppIconButton: UIButton {

    enum Metric {
        static let size: CGFloat = 44
        static let padding: CGFloat = 10
        static let highlightAlpha: CGFloat = 0.12
        static let scale: CGFloat = 0.94
    }
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConfiguration()
        setupLayout()
        setupHighlightFeedback()
        setupAccessibility()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupConfiguration() {
        var config = UIButton.Configuration.plain()

        config.contentInsets = NSDirectionalEdgeInsets(
            top: Metric.padding,
            leading: Metric.padding,
            bottom: Metric.padding,
            trailing: Metric.padding
        )

        config.baseForegroundColor = .white
        config.background.backgroundColor = .clear
        config.background.cornerRadius = Metric.size / 2

        self.configuration = config
    }

    private func setupLayout() {
        snp.makeConstraints {
            $0.width.height.equalTo(Metric.size)
        }
    }

    private func setupHighlightFeedback() {
        configurationUpdateHandler = { [weak self] button in
            guard let self else { return }
            var config = button.configuration

            if button.isHighlighted {
                config?.background.backgroundColor =
                    UIColor.white.withAlphaComponent(Metric.highlightAlpha)

                // Button Tap Action Animation
                self.transform = CGAffineTransform(
                    scaleX: Metric.scale,
                    y: Metric.scale
                )
            } else {
                config?.background.backgroundColor = .clear
                self.transform = .identity
            }

            button.configuration = config
        }
    }

    private func setupAccessibility() {
        isAccessibilityElement = true
        accessibilityTraits = .button
    }
    
    // MARK: - Public API
    func setIcon(_ image: UIImage?) {
        configuration?.image = image
    }
}
