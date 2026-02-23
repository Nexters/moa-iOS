//
//  CalendarDataSource.swift
//  Moa
//
//  Created by 정도현 on 2/19/26.
//

import UIKit

final class CalendarDataSource {
    
    private(set) var currentDate: Date
    private let calendar: Calendar
    
    private var rawDayTypes: [String: CalendarDayType] = [:]
    
    init(calendar: Calendar = .current) {
        self.calendar = calendar
        self.currentDate = Date()
    }
    
    // MARK: - Public
    
    func days(for date: Date, selectedDate: Date? = nil) -> [CalendarDay?] {
        
        let start   = startOfMonth(for: date)
        let total   = daysInMonth(for: date)
        let leading = weekdayIndex(for: start)
        
        var result: [CalendarDay?] = Array(repeating: nil, count: leading)
        
        for day in 1...total {
            var comps = calendar.dateComponents([.year, .month], from: date)
            comps.day = day
            guard let d = calendar.date(from: comps) else { continue }
            
            let isToday    = calendar.isDateInToday(d)
            let isSelected = selectedDate.map { calendar.isDate(d, inSameDayAs: $0) } ?? false
            let baseType   = rawDayTypes[key(d)] ?? .none
            
            result.append(
                CalendarDay(
                    date: d,
                    contentType: baseType,
                    isToday: isToday,
                    isSelected: isSelected,
                    isCurrentMonth: true
                )
            )
        }
        
        while result.count < 42 { result.append(nil) }
        return result
    }

    /// 해당 월을 표시하는 데 실제로 필요한 행 수 (4~6)
    /// - leading(0~6) + daysInMonth(28~31) 기준으로 ceil 계산
    func rowCount(for date: Date) -> Int {
        let start   = startOfMonth(for: date)
        let total   = daysInMonth(for: date)
        let leading = weekdayIndex(for: start)
        return Int(ceil(Double(leading + total) / 7.0))
    }
    
    @discardableResult func moveToNextMonth() -> Date {
        guard canMoveToNextMonth() else { return currentDate }
        currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
        return currentDate
    }
    
    @discardableResult func moveToPreviousMonth() -> Date {
        currentDate = calendar.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
        return currentDate
    }
    
    func setRawDayType(_ type: CalendarDayType, for date: Date) {
        rawDayTypes[key(date)] = type
    }
    
    func resetAndApply(_ days: [CalendarDay]) {
        let monthPrefix = monthKeyPrefix(for: currentDate)
        rawDayTypes = rawDayTypes.filter { !$0.key.hasPrefix(monthPrefix) }
        for day in days {
            rawDayTypes[key(day.date)] = day.contentType
        }
    }
    
    func rawType(for date: Date) -> CalendarDayType {
        return rawDayTypes[key(date)] ?? .none
    }
    
    func monthTitle(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
    
    func canMoveToNextMonth() -> Bool {
        let now = Date()
        let currentMonthStart = startOfMonth(for: currentDate)
        let todayMonthStart   = startOfMonth(for: now)
        return currentMonthStart < todayMonthStart
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
        calendar.component(.weekday, from: date) - 1   // 일요일 = 0
    }
    
    private func key(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }
    
    private func monthKeyPrefix(for date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM"
        return f.string(from: date)
    }
}
