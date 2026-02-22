//
//  HomeEntity.swift
//  Moa
//
//  Created by 정도현 on 2/22/26.
//

import Foundation

struct HomeEntity: Equatable {
    let workplace: String?
    let workedEarnings: Int
    let standardSalary: Int
    let dailyPay: Int
    let type: WorkdayType
    let clockInTime: TimeIndicatorEntity?
    let clockOutTime: TimeIndicatorEntity?
}
