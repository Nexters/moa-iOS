//
//  AppButton.swift
//  Moa
//
//  Created by mirim on 1/26/26.
//

import UIKit

final class AppButton: UIButton {
    
    // MARK: - Style Models
    struct TextStyle {
        let font: UIFont
        let color: UIColor
    }
    
    struct StateStyle {
        let backgroundColor: UIColor
        let text: TextStyle
    }
    
    struct Style {
        let enabled: StateStyle
        let pressed: StateStyle
        let disabled: StateStyle
        
        let cornerRadius: CGFloat
        let verticalPadding: CGFloat
        let horizontalPadding: CGFloat?
    }
    
    // MARK: - Stored
    private var style: Style?
    private var baseConfiguration: UIButton.Configuration = .filled()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        var config = UIButton.Configuration.filled()
        config.titleAlignment = .center
        
        self.baseConfiguration = config
        self.configuration = config
        
        self.configurationUpdateHandler = { [weak self] button in
            guard let self else { return }
            self.applyCurrentStateStyle(to: button)
        }
    }
    
    // MARK: - Public API
    func applyStyle(_ style: Style) {
        self.style = style
        
        var config = baseConfiguration
        config.background.cornerRadius = style.cornerRadius
        
        let horizontal = style.horizontalPadding ?? .zero
        config.contentInsets = NSDirectionalEdgeInsets(
            top: style.verticalPadding,
            leading: horizontal,
            bottom: style.verticalPadding,
            trailing: horizontal
        )
        
        self.baseConfiguration = config
        self.configuration = config
        
        setNeedsUpdateConfiguration()
    }
    
    // MARK: - Private
    private func applyCurrentStateStyle(to button: UIButton) {
        guard let style else { return }
        
        let stateStyle: StateStyle
        if !button.isEnabled {
            stateStyle = style.disabled
        } else if button.isHighlighted {
            stateStyle = style.pressed
        } else {
            stateStyle = style.enabled
        }
        
        var config = self.baseConfiguration
        config.baseBackgroundColor = stateStyle.backgroundColor
        config.baseForegroundColor = stateStyle.text.color
        
        let title = button.currentTitle ?? ""
        var attrs = AttributeContainer()
        attrs.font = stateStyle.text.font
        attrs.foregroundColor = stateStyle.text.color
        config.attributedTitle = AttributedString(title, attributes: attrs)
        
        self.configuration = config
    }
}

extension AppButton.Style {
    static func primary(
        font: UIFont = AppTypography.t3_700.font(),
        cornerRadius: CGFloat = 32.0,
        verticalPadding: CGFloat = 16.0,
        horizontalPadding: CGFloat? = nil
    ) -> AppButton.Style {
        .init(
            enabled: .init(
                backgroundColor: AppColor.Btn.Primary.enable,
                text: .init(font: font, color: AppColor.IconAndText.highEmphasisReverse)
            ),
            pressed: .init(
                backgroundColor: AppColor.Btn.Primary.pressed,
                text: .init(font: font, color: AppColor.IconAndText.highEmphasisReverse)
            ),
            disabled: .init(
                backgroundColor: AppColor.Container.secondary,
                text: .init(font: font, color: AppColor.IconAndText.disabled)
            ),
            cornerRadius: cornerRadius,
            verticalPadding: verticalPadding,
            horizontalPadding: horizontalPadding
        )
    }
    
    static func secondary(
        font: UIFont = AppTypography.t3_700.font(),
        cornerRadius: CGFloat = 32.0,
        verticalPadding: CGFloat = 16.0,
        horizontalPadding: CGFloat? = nil
    ) -> AppButton.Style {
        .init(
            enabled: .init(
                backgroundColor: AppColor.Btn.Secondary.enable,
                text: .init(font: font, color: AppColor.IconAndText.highEmphasis)
            ),
            pressed: .init(
                backgroundColor: AppColor.Btn.Secondary.pressed,
                text: .init(font: font, color: AppColor.IconAndText.highEmphasis)
            ),
            disabled: .init(
                backgroundColor: AppColor.Container.secondary,
                text: .init(font: font, color: AppColor.IconAndText.disabled)
            ),
            cornerRadius: cornerRadius,
            verticalPadding: verticalPadding,
            horizontalPadding: horizontalPadding
        )
    }
    
    static func tertiary(
        font: UIFont = AppTypography.t3_700.font(),
        cornerRadius: CGFloat = 32.0,
        verticalPadding: CGFloat = 16.0,
        horizontalPadding: CGFloat? = nil
    ) -> AppButton.Style {
        .init(
            enabled: .init(
                backgroundColor: AppColor.Btn.Tertiary.enable,
                text: .init(font: font, color: AppColor.IconAndText.highEmphasisReverse)
            ),
            pressed: .init(
                backgroundColor: AppColor.Btn.Tertiary.pressed,
                text: .init(font: font, color: AppColor.IconAndText.highEmphasisReverse)
            ),
            disabled: .init(
                backgroundColor: AppColor.Container.secondary,
                text: .init(font: font, color: AppColor.IconAndText.disabled)
            ),
            cornerRadius: cornerRadius,
            verticalPadding: verticalPadding,
            horizontalPadding: horizontalPadding
        )
    }
}
