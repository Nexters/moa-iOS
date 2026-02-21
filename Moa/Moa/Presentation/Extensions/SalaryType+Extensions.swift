//
//  SalaryType+Extensions.swift
//  Moa
//
//  Created by mirim on 2/21/26.
//

import Foundation

extension SalaryType {
    var displayName: String {
        switch self {
        case .monthly: "월급"
        case .annual: "연봉"
        }
    }
}
