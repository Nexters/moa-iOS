//
//  WorkdayRepository.swift
//  Moa
//
//  Created by 정도현 on 2/21/26.
//

import Foundation

protocol WorkdayRepository {
    func fetchWorkday(date: String) async throws -> WorkdayEntity
    func updateWorkdayAll(
        date: String,
        request: WorkdayUpdateRequest
    ) async throws -> WorkdayEntity
    
    func updateClockOut(
        date: String,
        request: ClockEndRequest
    ) async throws -> WorkdayEntity
    
    func fetchHistory(
        year: Int,
        month: Int
    ) async throws -> [History]
    
    func fetchEarnings(
        year: Int,
        month: Int
    ) async throws -> EarningsEntity
}
