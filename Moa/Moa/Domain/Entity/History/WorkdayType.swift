//
//  WorkdayType.swift
//  Moa
//
//  Created by 정도현 on 2/22/26.
//

import UIKit

enum WorkdayType: String {
    case work = "WORK"
    case vacation = "VACATION"
    case none = "NONE"
    
    var moneyImg: UIImage {
        switch self {
        case .work, .vacation: return UIImage(resource: .Image.imgEmptyMoney)
        case .none: return UIImage(resource: .Image.imgVacationMoney)
        }
    }
    
    var amountLabelColor: UIColor {
        switch self {
        case .work, .vacation: return AppColor.IconAndText.green
        case .none: return AppColor.IconAndText.blue
        }
    }
    
    var bottomButtonText: String {
        switch self {
        case .work, .vacation:
            return "지금 출근하기"
        case .none:
            return "쉬는 날 출근하기"
        }
    }
    
    var bubbleLabelText: String {
        switch self {
        case .work, .vacation:
            return "자동 출근 예정"
        case .none:
            return "설마 쉬는 날 일하시나요?"
        }
    }
}

extension WorkdayType {
    
    init(serverValue: String) {
        self = WorkdayType(rawValue: serverValue) ?? .none
    }
}
