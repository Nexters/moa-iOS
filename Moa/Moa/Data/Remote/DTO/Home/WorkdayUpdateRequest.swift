//
//  WorkdayUpdateRequest.swift
//  Moa
//
//  Created by 정도현 on 2/21/26.
//

import Foundation

struct WorkdayUpdateRequest: Encodable {
    let type: String
    let clockInTime: String
    let clockOutTime: String
}
