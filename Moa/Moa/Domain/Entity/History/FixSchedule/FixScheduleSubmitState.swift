//
//  FixScheduleSubmitState.swift
//  Moa
//
//  Created by 정도현 on 3/17/26.
//

import Foundation

enum FixScheduleSubmitState: Equatable {
    case idle
    case submitting
    case success
    case failure(String)
}
