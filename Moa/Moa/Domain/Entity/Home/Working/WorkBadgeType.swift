//
//  WorkBadgeType.swift
//  Moa
//
//  Created by 정도현 on 3/17/26.
//

import UIKit

// MARK: - BadgeType

enum WorkBadgeType {
    case working
    case lunch
    case vacation
    case overtime

    var text: String {
        switch self {
        case .working:  return "근무 중"
        case .lunch:    return "점심시간"
        case .vacation: return "휴가"
        case .overtime: return "추가 근무"
        }
    }

    var indicateColor: UIColor {
        switch self {
        case .working:  return AppColor.IconAndText.green
        case .lunch:    return AppColor.IconAndText.blue
        case .vacation: return AppColor.IconAndText.blue
        case .overtime: return AppColor.IconAndText.error
        }
    }
}
