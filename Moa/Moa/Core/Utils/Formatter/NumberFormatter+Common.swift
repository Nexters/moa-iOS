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
        
        var hundredMillions = value / 100_000_000 // 억 단위
        let remainderAfterHundredMillions = value % 100_000_000 // 억 단위 이하
        
        if hundredMillions == 0 {
            // 1억 미만: 만원 단위 (천원 단위가 있으면 소수점 표시)
            let manWon = Double(value) / 10_000.0
            let rounded = (manWon * 10).rounded() / 10  // 소수점 첫째자리까지 반올림
            let formatted = rounded.truncatingRemainder(dividingBy: 1) == 0 
                ? String(format: "%.0f", rounded)
                : String(format: "%.1f", rounded)
            return "\(formatted)만원"
        } else {
            // 1억 이상
            let manWon = Double(remainderAfterHundredMillions) / 10_000.0
            let rounded = (manWon * 10).rounded() / 10  // 소수점 첫째자리까지 반올림
            
            // 반올림 결과가 10000만원 이상이면 억 단위로 올림
            if rounded >= 10_000 {
                hundredMillions += 1
                return "\(hundredMillions)억"
            }
            
            if rounded == 0 {
                return "\(hundredMillions)억"
            } else {
                let formatted = rounded.truncatingRemainder(dividingBy: 1) == 0 
                    ? String(format: "%.0f", rounded)
                    : String(format: "%.1f", rounded)
                return "\(hundredMillions)억 \(formatted)만원"
            }
        }
    }
}
