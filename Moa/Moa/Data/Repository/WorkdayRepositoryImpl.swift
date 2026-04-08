//
//  WorkdayRepositoryImpl.swift
//  Moa
//
//  Created by 정도현 on 2/21/26.
//

import Foundation

final class WorkdayRepositoryImpl: WorkdayRepository {
    private let apiClient: APIClient
    
    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
}

// MARK: - Private Network Helper

extension WorkdayRepositoryImpl {
    
    func fetchCalendarEvent(year: Int, month: Int) async throws -> CalendarEntity {
        let response: CalendarResponse = try await apiClient.request(
            CalendarAPI.getCalendarInfo(year: year, month: month)
        )
        
        return response.toDomain()
    }
    
    func updateWorkdayAll(
        date: String,
        request: WorkdayUpdateRequest
    ) async throws -> CalendarScheduleEntity {
        let response: ScheduleResponse = try await apiClient.request(
            WorkdayAPI.updateWorkdayAll(date: date, body: request)
        )
        
        return response.toDomain()
    }
    
    func updateClockOut(
        date: String,
        request: ClockEndRequest
    ) async throws -> CalendarScheduleEntity {
        let response: ScheduleResponse = try await apiClient.request(
            WorkdayAPI.updateWorkdayClockEnd(date: date, body: request)
        )
        
        return response.toDomain()
    }
}
