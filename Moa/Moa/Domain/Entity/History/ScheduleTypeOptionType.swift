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
    
    var title: String {
        switch self {
        case .vacation:
            return "휴가"
        case .workday:
            return "근무"
        }
    }
}
