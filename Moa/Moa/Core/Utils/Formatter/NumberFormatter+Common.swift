//
//  NumberFormatter+Common.swift
//  Moa
//
//  Created by 정도현 on 2/2/26.
//

import Foundation

enum AppNumberFormatter {

    static let decimal: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()

    static func decimalString(from value: Int) -> String {
        decimal.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}
