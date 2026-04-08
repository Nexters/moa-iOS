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
