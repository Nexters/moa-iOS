//
//  StyledLabel.swift
//  Moa
//
//  Created by mirim on 1/26/26.
//

import UIKit

final class StyledLabel: UILabel {

    // MARK: - Style

    private var textStyle: TextStyle?
    
    // MARK: - Source of truth
    
    private var rawText: String = ""
    
    // MARK: Public API
    
    func setText(_ text: String?, style: TextStyle? = nil) {
        rawText = text ?? ""
        if let style { self.textStyle = style }
        applyStyle()
    }
    
    func setStyle(_ style: TextStyle) {
        self.textStyle = style
        applyStyle()
    }

    // MARK: - Private

    private func applyStyle() {
        guard let style = textStyle else { return }
        let content = rawText
        attributedText = style.makeAttributedString(content, alignment: textAlignment, lineBreakMode: lineBreakMode)
    }
}
