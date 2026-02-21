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
        setupSampleData()
    }
    
    // MARK: Public
    
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
            
            var baseType = rawDayTypes[key(d)] ?? .none
            
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
    
    /// delegate에 전달할 원본 타입 반환
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
    
    // MARK: Private
    
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
    
    private func setupSampleData() {
        var c = calendar.dateComponents([.year, .month], from: currentDate)
        let samples: [(Int, CalendarDayType)] = [
            (1,  .none),
            (3,  .scheduled),
            (5,  .worked),
            (8,  .worked),
            (10, .worked),
            (12, .worked),
            (15, .worked),
            (17, .singleLabel(.vacation)),
            (19, .singleLabel(.payday)),
            (22, .worked),
            (24, .worked),
            (25, .dualLabel),
        ]
        for (day, type) in samples {
            c.day = day
            if let d = calendar.date(from: c) { setRawDayType(type, for: d) }
        }
    }
}
