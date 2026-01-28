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
}
