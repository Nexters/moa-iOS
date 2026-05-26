//
//  WorkScheduleType.swift
//  Moa
//
//  Created by 정도현 on 3/17/26.
//

import UIKit

// MARK: - WorkScheduleType

enum WorkScheduleType {
    case worked(startTime: String, endTime: String)
    case scheduled(startTime: String, endTime: String)
    case payday(schedule: String, salary: String)   // e.g. "매달 25일", "2,000,000"
    case vacation(startTime: String, endTime: String)
    case publicHoliday

    var titleText: String {
        switch self {
        case .worked:    return "근무 완료"
        case .scheduled: return "근무 예정"
        case let .payday(schedule, _):    return "월급날 · 매달 \(schedule)일"
        case .vacation:  return "연차"
        case .publicHoliday: return "공휴일"
        }
    }

    /// titleLabel 오른쪽 보조 텍스트 (payday만 사용)
    var subtitleText: String? {
        guard case .payday(let schedule, _) = self else { return nil }
        return schedule
    }

    var mainText: String {
        switch self {
        case .worked(let s, let e),
             .scheduled(let s, let e),
             .vacation(let s, let e): return "\(s) - \(e)"
        case .payday(_, let salary):  return "\(salary)원"
        case .publicHoliday: return "근무 일정 없음"
        }
    }

    var mainColor: UIColor {
        return AppColor.IconAndText.highEmphasis
    }

    var iconImage: UIImage? {
        switch self {
        case .worked:    return UIImage(resource: .Icon.iconTicketWorked)
        case .scheduled: return UIImage(resource: .Icon.iconTicketScheduled)
        case .payday:    return UIImage(resource: .Icon.iconTicketPayday)
        case .vacation, .publicHoliday:  return UIImage(resource: .Icon.iconTicketVacation)
        }
    }
}
