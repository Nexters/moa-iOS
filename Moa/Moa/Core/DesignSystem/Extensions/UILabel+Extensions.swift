//
//  UILabel+Extensions.swift
//  Moa
//
//  Created by mirim on 1/26/26.
//

import UIKit

extension UILabel {
    func applyTextStyle(_ style: TextStyle, text: String? = nil) {
        let content = text ?? self.text ?? ""
        self.font = style.typography.font()
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.minimumLineHeight = style.typography.lineHeight
        paragraph.maximumLineHeight = style.typography.lineHeight
        paragraph.alignment = self.textAlignment
        
        let baselineOffset = (style.typography.lineHeight - style.typography.fontSize) / 2
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: style.typography.font(),
            .kern: style.typography.letterSpacing,
            .paragraphStyle: paragraph,
            .baselineOffset: baselineOffset,
            .foregroundColor: style.color
        ]
        
        self.attributedText = NSAttributedString(string: content, attributes: attributes)
    }
}
