//
//  TypographyStyle.swift
//  Moa
//
//  Created by mirim on 1/26/26.
//

import UIKit

struct TypographyStyle {
    let fontSize: CGFloat
    let weight: AppFontWeight
    let lineHeight: CGFloat
    let letterSpacing: CGFloat
    
    func font() -> UIFont {
        return UIFont(name: weight.fontName, size: fontSize)
        ?? UIFont.systemFont(ofSize: fontSize, weight: weight.systemFallback)
    }
}
