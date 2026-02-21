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
    
    func fetchWorkday(date: String) async throws -> Workday {
        let response: WorkdayResponse = try await apiClient.request(
            WorkdayAPI.getWorkday(date: date)
        )
        return response.toDomain()
    }
    
    func updateWorkdayAll(
        date: String,
        request: WorkdayUpdateRequest
    ) async throws -> Workday {
        let response: WorkdayResponse = try await apiClient.request(
            WorkdayAPI.updateWorkdayAll(date: date, body: request)
        )
        
        return response.toDomain()
    }
    
    func updateClockOut(
        date: String,
        request: ClockEndRequest
    ) async throws -> Workday {
        let response: WorkdayResponse = try await apiClient.request(
            WorkdayAPI.updateWorkdayClockEnd(date: date, body: request)
        )
        
        return response.toDomain()
    }
    
    func fetchHistory(
        year: Int,
        month: Int
    ) async throws -> [History] {
        let response: HistoryListResponse = try await apiClient.request(
            WorkdayAPI.getWorkdayList(year: year, month: month)
        )
        
        return response.content.map { $0.toDomain() }
    }
}
