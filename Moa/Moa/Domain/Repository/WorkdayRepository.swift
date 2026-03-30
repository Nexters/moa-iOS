//
//  WorkdayRepository.swift
//  Moa
//
//  Created by 정도현 on 2/21/26.
//

import Foundation

protocol WorkdayRepository {
    
    func fetchCalendarEvent(
        year: Int,
        month: Int
    ) async throws -> CalendarEntity
    
    func updateWorkdayAll(
        date: String,
        request: WorkdayUpdateRequest
    ) async throws -> CalendarScheduleEntity
    
    func updateClockOut(
        date: String,
        request: ClockEndRequest
    ) async throws -> CalendarScheduleEntity
}
