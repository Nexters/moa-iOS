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
    
    static func koreanCurrencyText(for value: Int) -> String {
        if value < 10_000 { return "" }
        let hundredMillions = value / 100_000_000
        let remainderAfterHundredMillions = value % 100_000_000
        let tenThousands = remainderAfterHundredMillions / 10_000
        if hundredMillions == 0 {
            return "\(tenThousands)만원"
        } else {
            if tenThousands == 0 {
                return "\(hundredMillions)억"
            } else {
                return "\(hundredMillions)억 \(tenThousands)만원"
            }
        }
    }
}
