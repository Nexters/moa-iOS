//
//  HomeUsecase.swift
//  Moa
//
//  Created by 정도현 on 2/22/26.
//

import Foundation

final class HomeUsecase {
    
    private let homeRepository: HomeRepository
    private let workdayRepository: WorkdayRepository
    
    init(
        homeRepository: HomeRepository,
        workdayRepository: WorkdayRepository
    ) {
        self.homeRepository = homeRepository
        self.workdayRepository = workdayRepository
    }
    
    // 홈 데이터 가져옴
    func getHomeData() async throws -> HomeEntity {
        try await homeRepository.fetchData()
    }
    
    // Type, 출퇴근 시간 업데이트
    func updateWorkday(
        date: String,
        type: WorkdayType,
        clockInTime: TimeIndicatorEntity,
        clockOutTime: TimeIndicatorEntity
    ) async throws -> WorkdayEntity {
        try await workdayRepository.updateWorkdayAll(
            date: date,
            request: WorkdayUpdateRequest(
                type: type.rawValue,
                clockInTime: clockInTime.displayString,
                clockOutTime: clockOutTime.displayString
            )
        )
    }
    
    // 퇴근시간 업데이트
    func updateClockOutTime(
        date: String,
        clockOutTime: TimeIndicatorEntity
    ) async throws -> WorkdayEntity {
        try await workdayRepository.updateClockOut(
            date: date,
            request: ClockEndRequest(
                clockOutTime: clockOutTime.displayString
            )
        )
    }
}
