//
//  WorkdayResponse.swift
//  Moa
//
//  Created by 정도현 on 2/21/26.
//

import Foundation

struct WorkdayResponse: Decodable {
    let date: String
    let type: String
    let clockInTime: String
    let clockOutTime: String
}

extension WorkdayResponse {
    func toDomain() -> Workday {
        Workday(
            date: date,
            type: type,
            clockInTime: clockInTime,
            clockOutTime: clockOutTime
        )
    }
}
