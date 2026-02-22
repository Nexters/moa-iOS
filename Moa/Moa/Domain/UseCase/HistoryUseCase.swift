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
    
    func getWorkdayList(year: Int, month: Int) async throws -> [History] {
        try await workdayRepository.fetchHistory(year: year, month: month)
    }

    func updateWorkday(
        date: String,
        type: WorkdayType,
        clockInTime: TimeIndicatorEntity?,
        clockOutTime: TimeIndicatorEntity?
    ) async throws -> WorkdayEntity {
        try await workdayRepository.updateWorkdayAll(
            date: date,
            request: WorkdayUpdateRequest(
                type: type.rawValue,
                clockInTime: clockInTime?.displayString,
                clockOutTime: clockOutTime?.displayString
            )
        )
    }
    
    func getEarningsInfo(year: Int, month: Int) async throws -> EarningsEntity {
        try await workdayRepository.fetchEarnings(year: year, month: month)
    }
}
