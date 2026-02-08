//
//  AppUnderlineButton.swift
//  Moa
//
//  Created by 정도현 on 2/4/26.
//

import UIKit

final class UnderlineTextButton: UIButton {
    
    // MARK: - Style
    
    struct Style {
        let font: UIFont
        let color: UIColor
        let pressedAlpha: CGFloat
        
        static let `default` = Style(
            font: AppTypography.b2_600.font(),
            color: AppColor.IconAndText.mediumEmphasis,
            pressedAlpha: 0.6
        )
    }
    
    // MARK: - Properties
    
    private var style: Style = .default
    private var titleText: String = ""
    
    // MARK: - Init
    
    init(title: String, style: Style = .default) {
        super.init(frame: .zero)
        self.titleText = title
        self.style = style
        setupUI()
        applyTitle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor = .clear
        
        addTarget(self, action: #selector(didTouchDown), for: .touchDown)
        addTarget(self, action: #selector(didTouchUp), for: [.touchUpInside, .touchCancel, .touchDragExit])
    }
    
    // MARK: - Action
    
    @objc private func didTouchDown() {
        alpha = style.pressedAlpha
    }
    
    @objc private func didTouchUp() {
        alpha = 1.0
    }
    
    // MARK: - Apply
    
    private func applyTitle() {
        let attributed = NSAttributedString(
            string: titleText,
            attributes: [
                .font: style.font,
                .foregroundColor: style.color,
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ]
        )
        
        setAttributedTitle(attributed, for: .normal)
    }
    
    // MARK: - Public
    
    func updateTitle(_ title: String) {
        self.titleText = title
        applyTitle()
    }
    
    func updateStyle(_ style: Style) {
        self.style = style
        applyTitle()
    }
}
