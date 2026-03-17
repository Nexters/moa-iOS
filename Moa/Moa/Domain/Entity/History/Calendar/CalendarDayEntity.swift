//
//  CalendarDayEntity.swift
//  Moa
//
//  Created by 정도현 on 3/17/26.
//

import Foundation

struct CalendarDayEntity: Equatable {
    let date: Date
    let contentType: CalendarDayType
    let isToday: Bool
    let isSelected: Bool
    let isCurrentMonth: Bool
}
