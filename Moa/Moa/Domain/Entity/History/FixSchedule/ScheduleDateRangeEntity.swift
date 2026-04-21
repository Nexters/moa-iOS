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

    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일"
        return formatter
    }()

    private static let serverFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone   = TimeZone(identifier: "Asia/Seoul")
        return formatter
    }()

    func formatted(_ date: Date) -> String { Self.formatter.string(from: date) }

    var displayString: String {
        if Calendar.current.isDate(start, inSameDayAs: end) {
            return formatted(start)
        }
        return "\(formatted(start)) ~ \(formatted(end))"
    }

    /// API 전송용 "yyyy-MM-dd" 문자열
    var startDateString: String { Self.serverFormatter.string(from: start) }

    init(single date: Date)      { self.start = date; self.end = date }
    init(start: Date, end: Date) { self.start = start; self.end = end }
}
