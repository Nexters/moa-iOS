//
//  HistoryViewState.swift
//  Moa
//
//  Created by 정도현 on 3/17/26.
//

import Foundation

enum HistoryViewState: Equatable {
    case idle
    case loading
    case loaded(schedules: [CalendarScheduleEntity], earnings: EarningsEntity)
    case dayDetail(schedule: CalendarScheduleEntity, salary: Int)
    case error(HistoryError)
}
