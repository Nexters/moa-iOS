//
//  SalaryType.swift
//  Moa
//
//  Created by mirim on 2/4/26.
//

import Foundation

enum SalaryType {
    case monthly
    case annual
    
    var maxDigits: Int {
        switch self {
        case .monthly: 9
        case .annual: 10
        }
    }
}
