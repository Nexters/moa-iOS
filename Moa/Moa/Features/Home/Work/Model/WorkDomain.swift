//
//  WorkDomain.swift
//  Moa
//
//  Created by 정도현 on 2/21/26.
//

import UIKit

// MARK: - WorkingType

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

    var badgeType: BadgeType {
        switch self {
        case .work:     return .working
        case .vacation: return .vacation
        }
    }
}

// MARK: - WorkStatus

enum WorkStatus: Equatable {
    case idle                           // 출근 전 (버튼 대기)
    case working
    case finished

    var isActive: Bool {
        switch self {
        case .working   : return true
        default:          return false
        }
    }
}

// MARK: - WorkViewState

enum WorkViewState: Equatable {
    case idle
    case loading
    case loaded(status: WorkStatus, data: HomeEntity)
    case error(WorkViewError)
}

// MARK: - WorkViewError

enum WorkViewError: LocalizedError, Equatable {
    case network
    case dataCorrupted
    case unauthorized
    case invalidWorkTime
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .network:          return "네트워크 연결을 확인해주세요."
        case .dataCorrupted:    return "데이터를 처리하는 중 문제가 발생했습니다."
        case .unauthorized:     return "로그인이 필요합니다."
        case .invalidWorkTime:  return "종료 시간이 시작 시간보다 빨라요."
        case .unknown(let msg): return msg
        }
    }
}
