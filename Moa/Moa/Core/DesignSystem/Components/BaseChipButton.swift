//
//  BaseChipButton.swift
//  Moa
//
//  Created by mirim on 2/4/26.
//

import UIKit

/// 선택/비선택 상태에 따라 스타일(배경·텍스트·폰트 등)을 일관되게 적용하기 위한 공통 칩 버튼 베이스
class BaseChipButton: UIButton {
    
    struct Style {
        var cornerRadius: CGFloat
        var contentInsets: NSDirectionalEdgeInsets
        
        var fontNormal: UIFont
        var fontSelected: UIFont
        
        var bgNormal: UIColor
        var bgSelected: UIColor
        
        var fgNormal: UIColor
        var fgSelected: UIColor
    }
    
    var style: Style { didSet { setNeedsUpdateConfiguration() } }
    var togglesSelectionOnTap: Bool = true
    
    init(title: String, style: Style) {
        self.style = style
        super.init(frame: .zero)
        
        setTitle(title, for: .normal)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        var config = UIButton.Configuration.plain()
        config.contentInsets = style.contentInsets
        configuration = config
        
        configurationUpdateHandler = { [weak self] button in
            guard self != nil, let button = button as? BaseChipButton else { return }
            button.apply()
        }
        
        addAction(
            UIAction(
                handler: { [weak self] _ in
                    guard let self else { return }
                    if self.togglesSelectionOnTap, self.isEnabled {
                        self.isSelected.toggle()
                    }
                }
            ),
            for: .touchUpInside
        )
        
        setNeedsUpdateConfiguration()
    }
    
    private func apply() {
        var title = AttributedString(currentTitle ?? "")
        title.font = isSelected ? style.fontSelected : style.fontNormal
        
        let bg: UIColor
        let fg: UIColor
        
        bg = isSelected ? style.bgSelected : style.bgNormal
        fg = isSelected ? style.fgSelected : style.fgNormal
        
        title.foregroundColor = fg
        
        var config = configuration ?? .plain()
        config.attributedTitle = title
        config.background.backgroundColor = bg
        config.background.cornerRadius = style.cornerRadius
        config.contentInsets = style.contentInsets
        configuration = config
    }
}
