//
//  CalendarResponse.swift
//  Moa
//
//  Created by 정도현 on 3/30/26.
//

import Foundation

struct CalendarResponse: Decodable {
    let earnings:  EarningsResponse
    let schedules: [ScheduleResponse]
    let joinedAt:  String
}

extension CalendarResponse {
    func toDomain() -> CalendarEntity {
        CalendarEntity(
            earnings: earnings.toDomain(),
            schedules: schedules.map { $0.toDomain() },
            joinedAt: Date.parseDate(joinedAt) ?? Date()
        )
    }
}
