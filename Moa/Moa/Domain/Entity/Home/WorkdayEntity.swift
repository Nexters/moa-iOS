//
//  Workday.swift
//  Moa
//
//  Created by 정도현 on 2/21/26.
//

import Foundation

struct WorkdayEntity: Equatable {
    let date: String
    let type: WorkdayType
    let clockInTime: TimeIndicatorEntity?
    let clockOutTime: TimeIndicatorEntity?
}
