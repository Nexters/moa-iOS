//
//  UILabel+Extensions.swift
//  Moa
//
//  Created by mirim on 1/26/26.
//

import UIKit

extension UILabel {
    func applyTypography(_ style: TypographyStyle, text: String? = nil) {
        let content = text ?? self.text ?? ""
        self.font = style.font()
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.minimumLineHeight = style.lineHeight
        paragraph.maximumLineHeight = style.lineHeight
        
        let baselineOffset = (style.lineHeight - style.fontSize) / 2
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: style.font(),
            .kern: style.letterSpacing,
            .paragraphStyle: paragraph,
            .baselineOffset: baselineOffset
        ]
        
        self.attributedText = NSAttributedString(string: content, attributes: attributes)
    }
}
