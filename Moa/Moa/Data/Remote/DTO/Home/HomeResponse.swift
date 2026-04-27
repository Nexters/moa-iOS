//
//  HomeResponse.swift
//  Moa
//
//  Created by 정도현 on 2/22/26.
//

import Foundation

struct HomeResponse: Decodable {
    let workplace: String?
    let workedEarnings: Int
    let standardSalary: Int
    let dailyPay: Int
    let type: String
    let status: String
    let events: [String]
    let clockInTime: String?
    let clockOutTime: String?
}

extension HomeResponse {
    func toDomain() -> HomeEntity {
        HomeEntity(
            workplace: workplace,
            workedEarnings: workedEarnings,
            standardSalary: standardSalary,
            dailyPay: dailyPay,
            type: WorkdayType(serverValue: type),
            status: CalendarScheduleStatus(rawValue: status)  ?? .none,
            events: events.compactMap { CalendarEventType(rawValue: $0) },
            clockInTime: TimeIndicatorEntity(from: clockInTime),
            clockOutTime: TimeIndicatorEntity(from: clockOutTime)
        )
    }
}
