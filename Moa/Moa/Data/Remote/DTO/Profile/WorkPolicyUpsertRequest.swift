//
//  WorkPolicyUpsertRequest.swift
//  Moa
//
//  Created by mirim on 2/18/26.
//

import Foundation

struct WorkPolicyUpsertRequest: Encodable {
    let workdays: [String] // 최소 1개 이상
    let clockInTime: String?
    let clockOutTime: String?
}
