//
//  TextStyle.swift
//  Moa
//
//  Created by mirim on 1/28/26.
//

import UIKit

struct TextStyle {
    let typography: TypographyStyle
    let color: UIColor

    init(typography: TypographyStyle, color: UIColor) {
        self.typography = typography
        self.color = color
    }
    
    func makeAttributedString(
        _ text: String,
        alignment: NSTextAlignment,
        lineBreakMode: NSLineBreakMode = .byWordWrapping
    ) -> NSAttributedString {
        let paragraph = NSMutableParagraphStyle()
        paragraph.minimumLineHeight = typography.lineHeight
        paragraph.alignment = alignment
        paragraph.lineBreakMode = lineBreakMode

        let baselineOffset = (typography.lineHeight - typography.fontSize) / 2

        let attributes: [NSAttributedString.Key: Any] = [
            .font: typography.font(),
            .kern: typography.letterSpacing,
            .paragraphStyle: paragraph,
            .baselineOffset: baselineOffset,
            .foregroundColor: color
        ]

        return NSAttributedString(string: text, attributes: attributes)
    }
}
