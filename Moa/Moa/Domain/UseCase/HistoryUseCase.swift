//
//  HistoryUseCase.swift
//  Moa
//
//  Created by 정도현 on 2/22/26.
//

import Foundation

final class HistoryUseCase {
    
    private let workdayRepository: WorkdayRepository
    
    init(
        workdayRepository: WorkdayRepository
    ) {
        self.workdayRepository = workdayRepository
    }
    
    func getCalendarData(year: Int, month: Int) async throws -> CalendarEntity {
        try await workdayRepository.fetchCalendarEvent(year: year, month: month)
    }

    func updateWorkday(
        date: String,
        type: WorkdayType,
        clockInTime: TimeIndicatorEntity?,
        clockOutTime: TimeIndicatorEntity?
    ) async throws -> CalendarScheduleEntity {
        try await workdayRepository.updateWorkdayAll(
            date: date,
            request: WorkdayUpdateRequest(
                type: type.rawValue,
                clockInTime: clockInTime?.displayString,
                clockOutTime: clockOutTime?.displayString
            )
        )
    }
}
