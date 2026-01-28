//
//  AppTypography.swift
//  Moa
//
//  Created by mirim on 1/25/26.
//

import UIKit

enum AppTypography {
    // MARK: - Headline
    static let h1_700 = TypographyStyle(fontSize: 40, weight: .bold, lineHeight: 50, letterSpacing: -0.2)
    static let h2_700 = TypographyStyle(fontSize: 36, weight: .bold, lineHeight: 48, letterSpacing: -0.2)
    static let h2_500 = TypographyStyle(fontSize: 36, weight: .medium, lineHeight: 48, letterSpacing: -0.2)
    static let h3_700 = TypographyStyle(fontSize: 28, weight: .bold, lineHeight: 38, letterSpacing: -0.2)
    static let h3_500 = TypographyStyle(fontSize: 28, weight: .medium, lineHeight: 38, letterSpacing: -0.2)

    // MARK: - Title
    static let t1_700 = TypographyStyle(fontSize: 24, weight: .bold, lineHeight: 34, letterSpacing: -0.2)
    static let t1_500 = TypographyStyle(fontSize: 24, weight: .medium, lineHeight: 34, letterSpacing: -0.2)
    static let t1_400 = TypographyStyle(fontSize: 24, weight: .regular, lineHeight: 34, letterSpacing: -0.2)

    static let t2_700 = TypographyStyle(fontSize: 20, weight: .bold, lineHeight: 28, letterSpacing: -0.2)
    static let t2_500 = TypographyStyle(fontSize: 20, weight: .medium, lineHeight: 28, letterSpacing: -0.2)
    static let t2_400 = TypographyStyle(fontSize: 20, weight: .regular, lineHeight: 28, letterSpacing: -0.2)

    static let t3_700 = TypographyStyle(fontSize: 18, weight: .bold, lineHeight: 26, letterSpacing: -0.2)
    static let t3_500 = TypographyStyle(fontSize: 18, weight: .medium, lineHeight: 26, letterSpacing: -0.2)
    static let t3_400 = TypographyStyle(fontSize: 18, weight: .regular, lineHeight: 26, letterSpacing: -0.2)

    // MARK: - Body
    static let b1_600 = TypographyStyle(fontSize: 16, weight: .semiBold, lineHeight: 24, letterSpacing: -0.2)
    static let b1_500 = TypographyStyle(fontSize: 16, weight: .medium, lineHeight: 24, letterSpacing: -0.2)
    static let b1_400 = TypographyStyle(fontSize: 16, weight: .regular, lineHeight: 24, letterSpacing: -0.2)

    static let b2_600 = TypographyStyle(fontSize: 14, weight: .semiBold, lineHeight: 21, letterSpacing: -0.2)
    static let b2_500 = TypographyStyle(fontSize: 14, weight: .medium, lineHeight: 21, letterSpacing: -0.2)
    static let b2_400 = TypographyStyle(fontSize: 14, weight: .regular, lineHeight: 21, letterSpacing: -0.2)

    // MARK: - Caption
    static let c1_600 = TypographyStyle(fontSize: 12, weight: .semiBold, lineHeight: 18, letterSpacing: -0.2)
    static let c1_500 = TypographyStyle(fontSize: 12, weight: .medium, lineHeight: 18, letterSpacing: -0.2)
    static let c1_400 = TypographyStyle(fontSize: 12, weight: .regular, lineHeight: 18, letterSpacing: -0.2)

    static let c2_600 = TypographyStyle(fontSize: 10, weight: .semiBold, lineHeight: 15, letterSpacing: -0.2)
    static let c2_500 = TypographyStyle(fontSize: 10, weight: .medium, lineHeight: 15, letterSpacing: -0.2)
    static let c2_400 = TypographyStyle(fontSize: 10, weight: .regular, lineHeight: 15, letterSpacing: -0.2)
}
