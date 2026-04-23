//
//  ScheduleDateRangeEntity.swift
//  Moa
//
//  Created by 정도현 on 3/17/26.
//

import UIKit

// MARK: - ScheduleDateRange

struct ScheduleDateRangeEntity: Equatable {
    let start: Date
    let end:   Date

    func formatted(_ date: Date) -> String { DateFormatter.koreanDateLong.string(from: date) }

    var displayString: String {
        if Calendar.current.isDate(start, inSameDayAs: end) {
            return formatted(start)
        }
        return "\(formatted(start)) ~ \(formatted(end))"
    }

    /// API 전송용 "yyyy-MM-dd" 문자열
    var startDateString: String { DateFormatter.yyyyMMdd.string(from: start) }

    init(single date: Date)      { self.start = date; self.end = date }
    init(start: Date, end: Date) { self.start = start; self.end = end }
}
