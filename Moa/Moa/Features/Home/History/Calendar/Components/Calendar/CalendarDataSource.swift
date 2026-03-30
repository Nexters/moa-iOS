//
//  CalendarDataSource.swift
//  Moa
//

import UIKit

final class CalendarDataSource {

    private(set) var currentDate: Date
    private let calendar: Calendar

    /// 날짜 키 → CalendarScheduleEntity 매핑
    private var rawSchedules: [String: CalendarScheduleEntity] = [:]

    init(calendar: Calendar = .current) {
        self.calendar    = calendar
        self.currentDate = Date()
    }

    // MARK: - Public

    func days(for date: Date, selectedDate: Date? = nil) -> [CalendarScheduleEntity?] {
        let start   = startOfMonth(for: date)
        let total   = daysInMonth(for: date)
        let leading = weekdayIndex(for: start)

        var result: [CalendarScheduleEntity?] = Array(repeating: nil, count: leading)

        for day in 1...total {
            var comps  = calendar.dateComponents([.year, .month], from: date)
            comps.day  = day
            guard let d = calendar.date(from: comps) else { continue }

            let isToday    = calendar.isDateInToday(d)
            let isSelected = selectedDate.map { calendar.isDate(d, inSameDayAs: $0) } ?? false

            if var schedule = rawSchedules[key(d)] {
                // API에서 받은 데이터 사용 — isToday, isSelected 갱신
                schedule.isToday    = isToday
                schedule.isSelected = isSelected
                result.append(schedule)
            } else {
                // API 데이터 없는 날 → 빈 셀
                result.append(
                    CalendarScheduleEntity(
                        date:           d,
                        contentType:    .none,
                        status:         .none,
                        events:         [],
                        dailyPay:       0,
                        clockInTime:    nil,
                        clockOutTime:   nil,
                        isToday:        isToday,
                        isSelected:     isSelected,
                        isCurrentMonth: true
                    )
                )
            }
        }

        while result.count < 42 { result.append(nil) }
        return result
    }

    func rowCount(for date: Date) -> Int {
        let start   = startOfMonth(for: date)
        let total   = daysInMonth(for: date)
        let leading = weekdayIndex(for: start)
        return Int(ceil(Double(leading + total) / 7.0))
    }

    @discardableResult func moveToNextMonth() -> Date {
        currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
        return currentDate
    }

    @discardableResult func moveToPreviousMonth() -> Date {
        currentDate = calendar.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
        return currentDate
    }

    /// API에서 받은 CalendarScheduleEntity 배열로 현재 월 데이터 교체
    func resetAndApply(_ schedules: [CalendarScheduleEntity]) {
        let monthPrefix = monthKeyPrefix(for: currentDate)
        rawSchedules    = rawSchedules.filter { !$0.key.hasPrefix(monthPrefix) }
        for schedule in schedules {
            rawSchedules[key(schedule.date)] = schedule
        }
    }

    /// 특정 날짜의 원본 CalendarScheduleEntity 반환
    func rawSchedule(for date: Date) -> CalendarScheduleEntity? {
        rawSchedules[key(date)]
    }

    func monthTitle(for date: Date) -> String {
        let formatter        = DateFormatter()
        formatter.dateFormat = "M월"
        formatter.locale     = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }

    // MARK: - Private

    private func startOfMonth(for date: Date) -> Date {
        let cal = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: cal) ?? date
    }

    private func daysInMonth(for date: Date) -> Int {
        calendar.range(of: .day, in: .month, for: date)?.count ?? 30
    }

    private func weekdayIndex(for date: Date) -> Int {
        calendar.component(.weekday, from: date) - 1
    }

    private func key(_ date: Date) -> String {
        let formatter        = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    private func monthKeyPrefix(for date: Date) -> String {
        let formatter        = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter.string(from: date)
    }
}
