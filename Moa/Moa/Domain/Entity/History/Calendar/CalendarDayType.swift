//
//  CalendarDayType.swift
//  Moa
//
//  Created by 정도현 on 3/17/26.
//

import Foundation

enum CalendarDayType: Equatable {
    case none
    case scheduled
    case worked
    case dualLabel
    case singleLabel(CalendarLabelStyle)
}
