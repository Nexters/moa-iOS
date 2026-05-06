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
        case .work: return UIImage(resource: .Image.imgEmptyMoney)
        case .vacation, .none: return UIImage(resource: .Image.imgVacationMoney)
        }
    }
    
    var amountLabelColor: UIColor {
        switch self {
        case .work: return AppColor.IconAndText.green
        case .none, .vacation: return AppColor.IconAndText.blue
        }
    }
    
    var bottomButtonText: String {
        switch self {
        case .work:
            return "지금 출근하기"
        case .vacation, .none:
            return "이번 달 일정 확인하기"
        }
    }
    
    var bubbleLabelText: String? {
        switch self {
        case .work:
            return "자동 출근 예정"
        case .vacation, .none:
            return nil
        }
    }
}

extension WorkdayType {
    
    init(serverValue: String) {
        self = WorkdayType(rawValue: serverValue) ?? .none
    }
}
