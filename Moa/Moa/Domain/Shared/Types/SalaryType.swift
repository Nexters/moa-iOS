//
//  SalaryType.swift
//  Moa
//
//  Created by mirim on 2/4/26.
//

import Foundation

enum SalaryType {
    case monthly
    case yearly
    
    var maxDigits: Int {
        switch self {
        case .monthly: 9
        case .yearly: 10
        }
    }
}
