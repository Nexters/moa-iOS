//
//  WorkdayRepository.swift
//  Moa
//
//  Created by 정도현 on 2/21/26.
//

import Foundation

protocol WorkdayRepository {
    func fetchWorkday(date: String) async throws -> Workday
    func updateWorkdayAll(
        date: String,
        request: WorkdayUpdateRequest
    ) async throws -> Workday
    
    func updateClockOut(
        date: String,
        request: ClockEndRequest
    ) async throws -> Workday
    
    func fetchHistory(
        year: Int,
        month: Int
    ) async throws -> [History]
}
