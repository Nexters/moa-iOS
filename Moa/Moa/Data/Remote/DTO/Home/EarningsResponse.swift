//
//  EarningsResponse.swift
//  Moa
//
//  Created by 정도현 on 2/23/26.
//

import Foundation

struct EarningsResponse: Decodable {
    let workedEarnings: Int
    let standardSalary: Int
    let workedMinutes: Int
    let standardMinutes: Int
}

extension EarningsResponse {
    func toDomain() -> EarningsEntity {
        EarningsEntity(
            workedEarnings: workedEarnings,
            standardSalary: standardSalary,
            workedMinutes: workedMinutes,
            standardMinutes: standardMinutes
        )
    }
}
