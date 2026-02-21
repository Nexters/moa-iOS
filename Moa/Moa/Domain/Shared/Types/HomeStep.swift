//
//  HomeStep.swift
//  Moa
//
//  Created by 정도현 on 2/20/26.
//

import Foundation

enum HomeStep: CaseIterable {
    case work
    case history
    case addSchedule
    case fixSchedule
    
    var orderIndex: Int {
        switch self {
        case .work: return 0
        case .history: return 1
        case .addSchedule: return 2
        case .fixSchedule: return 3
        }
    }
}
