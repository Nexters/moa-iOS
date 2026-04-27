//
//  ScheduleResponse.swift
//  Moa
//
//  Created by 정도현 on 3/30/26.
//

import Foundation

// MARK: - schedule
struct ScheduleResponse: Decodable {
    let date:        String         // "2026-03-29"
    let type:        String         // "WORK" | "VACATION" | "NONE"
    let status:      String         // "NONE" | "SCHEDULED" | "COMPLETED"
    let events:      [String]       // ["PAYDAY", "PUBLIC_HOLIDAY"] 등
    let dailyPay:    Int
    let clockInTime:  String?       // "09:00" (nullable)
    let clockOutTime: String?       // "18:00" (nullable)
}

extension ScheduleResponse {
    func toDomain() -> CalendarScheduleEntity {
        
        let date    = Date.parseDate(date) ?? Date()
        let today   = Calendar.current.startOfDay(for: Date())
        let isToday = Calendar.current.isDate(date, inSameDayAs: today)
        
        return CalendarScheduleEntity(
            date:           date,
            contentType:    WorkdayType(rawValue: type) ?? .none,
            status:         CalendarScheduleStatus(rawValue: status)  ?? .none,
            events:         events.compactMap { CalendarEventType(rawValue: $0) },
            dailyPay:       dailyPay,
            clockInTime:    TimeIndicatorEntity(from: clockInTime),
            clockOutTime:   TimeIndicatorEntity(from: clockOutTime),
            isToday:        isToday,
            isSelected:     false,
            isCurrentMonth: true
        )
    }
}
