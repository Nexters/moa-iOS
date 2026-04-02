//
//  CalendarDataSource.swift
//  Moa
//

import UIKit

final class CalendarDataSource {

    private(set) var currentDate: Date
    private let calendar: Calendar

    /// 가입일 — 이 달의 월 시작보다 이전으로는 이동 불가
    /// nil이면 제한 없음
    private var joinedAt: Date?

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
                schedule.isToday    = isToday
                schedule.isSelected = isSelected
                result.append(schedule)
            } else {
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

    // MARK: - Navigation

    /// 이전 달로 이동 가능한지 여부
    /// joinedAt이 설정된 경우, 현재 달의 월 시작이 가입 달의 월 시작보다 클 때만 허용
    var canMoveToPreviousMonth: Bool {
        guard let joinedAt else { return true }
        let currentMonthStart = startOfMonth(for: currentDate)
        let joinedMonthStart  = startOfMonth(for: joinedAt)
        return currentMonthStart > joinedMonthStart
    }

    @discardableResult func moveToNextMonth() -> Date {
        currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
        return currentDate
    }

    /// 이전 달로 이동. 가입 달이 설정된 경우 그 이전으로는 이동하지 않음.
    /// - Returns: 실제 이동 여부
    @discardableResult func moveToPreviousMonth() -> Bool {
        guard canMoveToPreviousMonth else { return false }
        currentDate = calendar.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
        return true
    }

    /// 가입일 설정 — CalendarEntity.joinedAt을 최초 loaded 시점에 한 번 전달
    func applyJoinedAt(_ date: Date) {
        guard joinedAt == nil else { return }  // 최초 1회만 설정
        joinedAt = date
    }

    // MARK: - Data

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
