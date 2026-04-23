//
//  ScheduleTypeOptionType.swift
//  Moa
//
//  Created by 정도현 on 3/17/26.
//

import Foundation

enum ScheduleTypeOptionType {
    case vacation
    case workday
    case none
    
    var title: String {
        switch self {
        case .vacation:
            return "연차"
        case .workday:
            return "근무"
        case .none:
            return "휴무"
        }
    }
}
