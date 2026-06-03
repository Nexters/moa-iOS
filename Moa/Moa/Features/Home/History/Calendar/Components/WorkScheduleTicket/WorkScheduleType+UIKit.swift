//
//  WorkScheduleType+UIKit.swift
//  Moa
//

import UIKit

extension WorkScheduleType {

    var iconImage: UIImage? {
        switch self {
        case .worked:                   return UIImage(resource: .Icon.iconTicketWorked)
        case .scheduled:                return UIImage(resource: .Icon.iconTicketScheduled)
        case .payday:                   return UIImage(resource: .Icon.iconTicketPayday)
        case .vacation, .publicHoliday: return UIImage(resource: .Icon.iconTicketVacation)
        }
    }

    var mainColor: UIColor {
        AppColor.IconAndText.highEmphasis
    }
}
