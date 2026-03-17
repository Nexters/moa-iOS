//
//  WorkingType.swift
//  Moa
//
//  Created by 정도현 on 3/17/26.
//

import UIKit

enum WorkingType {
    case work
    case vacation

    var stackImage: UIImage {
        switch self {
        case .work:     return UIImage(resource: .Image.imgWorkingMoneyStack)
        case .vacation: return UIImage(resource: .Image.imgVacationMoneyStack)
        }
    }

    var barColor: UIColor {
        switch self {
        case .work:     return AppColor.IconAndText.green
        case .vacation: return AppColor.IconAndText.blue
        }
    }

    var badgeType: WorkBadgeType {
        switch self {
        case .work:     return .working
        case .vacation: return .vacation
        }
    }
}
