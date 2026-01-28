//
//  AppFont.swift
//  Moa
//
//  Created by mirim on 1/25/26.
//

import UIKit

enum AppFontName {
    static let pretendardRegular = "Pretendard-Regular"
    static let pretendardMedium = "Pretendard-Medium"
    static let pretendardSemiBold = "Pretendard-SemiBold"
    static let pretendardBold = "Pretendard-Bold"
}

enum AppFontWeight {
    case regular, medium, semiBold, bold
    
    var fontName: String {
        switch self {
        case .regular: AppFontName.pretendardRegular
        case .medium: AppFontName.pretendardMedium
        case .semiBold: AppFontName.pretendardSemiBold
        case .bold: AppFontName.pretendardBold
        }
    }
    
    var systemFallback: UIFont.Weight {
        switch self {
        case .regular: .regular
        case .medium: .medium
        case .semiBold: .semibold
        case .bold: .bold
        }
    }
}
