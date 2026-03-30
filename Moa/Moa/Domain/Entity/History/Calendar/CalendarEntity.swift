//
//  CalendarEntity.swift
//  Moa
//
//  Created by 정도현 on 3/30/26.
//

import Foundation

struct CalendarEntity: Equatable {
    let earnings:  EarningsEntity
    let schedules:  [CalendarScheduleEntity]
    let joinedAt:  Date
}

// MARK: - CalendarDayType
//
// API "type" 필드에 대응
// NONE = 일정 없음(공휴일), WORK = 근무, VACATION = 휴가

enum CalendarScheduleType: String {
    case none     = "NONE"
    case work     = "WORK"
    case vacation = "VACATION"
}

// MARK: - CalendarDayStatus

enum CalendarScheduleStatus: String {
    case none     = "NONE"
    case scheduled  = "SCHEDULED"
    case completed = "COMPLETED"  // 완료
}

// MARK: - CalendarEvent
//
// API "events" 배열 항목에 대응

enum CalendarEvent: String {
    case payday = "PAYDAY"
}

// MARK: - CalendarDayEntity
//
// 캘린더 셀 하나에 대응하는 도메인 모델

struct CalendarScheduleEntity: Equatable {
    let date:          Date
    let contentType:   CalendarScheduleType
    let status:        CalendarScheduleStatus
    let events:        [CalendarEvent]
    let dailyPay:      Int
    let clockInTime:   TimeIndicatorEntity?
    let clockOutTime:  TimeIndicatorEntity?
    let isToday:       Bool
    var isSelected:    Bool
    let isCurrentMonth: Bool
}
