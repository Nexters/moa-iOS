//
//  WorkPolicyEntity.swift
//  Moa
//
//  Created by mirim on 2/18/26.
//

import Foundation

struct WorkPolicyEntity {
    let workdays: [Weekday]
    let clockInTime: TimeIndicatorEntity?
    let clockOutTime: TimeIndicatorEntity?
}
