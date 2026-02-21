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
}
