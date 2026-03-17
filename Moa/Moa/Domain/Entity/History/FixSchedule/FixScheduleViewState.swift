//
//  FixScheduleViewState.swift
//  Moa
//
//  Created by 정도현 on 3/17/26.
//

import Foundation

// MARK: - FixScheduleViewState

struct FixScheduleViewState: Equatable {
    var scheduleType: ScheduleTypeOptionType = .workday
    var dateRange:    ScheduleDateRangeEntity?     = nil
    var startTime:    TimeIndicatorEntity    = .from(hour: 9,  minute: 0)
    var endTime:      TimeIndicatorEntity    = .from(hour: 18, minute: 0)

    var isConfirmEnabled: Bool { dateRange != nil }
}
