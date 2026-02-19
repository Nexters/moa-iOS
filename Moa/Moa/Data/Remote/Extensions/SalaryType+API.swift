//
//  SalaryType+API.swift
//  Moa
//
//  Created by mirim on 2/18/26.
//

import Foundation

extension SalaryType {
    var apiValue: String {
        switch self {
        case .monthly: return "MONTHLY"
        case .annual:  return "ANNUAL"
        }
    }
}
