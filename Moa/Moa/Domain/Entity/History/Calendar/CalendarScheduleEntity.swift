//
//  CalendarScheduleEntity.swift
//  Moa
//
//  Created by 정도현 on 3/30/26.
//

import Foundation

// MARK: - CalendarScheduleEntity

struct CalendarScheduleEntity: Equatable {
    let date:          Date
    let contentType:   WorkdayType
    let status:        CalendarScheduleStatus
    let events:        [CalendarEventType]
    let dailyPay:      Int
    let clockInTime:   TimeIndicatorEntity?
    let clockOutTime:  TimeIndicatorEntity?
    var isToday:       Bool
    var isSelected:    Bool
    let isCurrentMonth: Bool
}
