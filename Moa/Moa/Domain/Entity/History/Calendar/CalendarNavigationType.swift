//
//  CalendarNavigationType.swift
//  Moa
//
//  Created by 정도현 on 3/17/26.
//

import Foundation

enum CalendarNavigationType {
    case history
    case bottomSheet
    
    var showsAddButton: Bool {
        switch self {
        case .history: return true
        case .bottomSheet: return false
        }
    }
}
