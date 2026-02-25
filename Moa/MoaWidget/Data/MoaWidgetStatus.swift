//
//  MoaWidgetStatus+UI.swift
//  Moa
//

import UIKit
import SwiftUI

extension MoaWidgetStatus {

    // MARK: - 뱃지 텍스트

    /// nil이면 뱃지 미표시
    var badgeTitle: String? {
        switch self {
        case .working:  return "근무 중"
        case .vacation: return "휴가"
        case .finished: return "완료"
        case .offline:  return "오프라인"
        case .lowPower: return "절전 모드"
        case .skeleton: return nil
        }
    }

    // MARK: - 금액 텍스트 색상

    var moneyColor: UIColor? {
        switch self {
        case .working, .finished: return AppColor.IconAndText.green
        case .vacation: return AppColor.IconAndText.blue
        case .offline, .lowPower, .skeleton: return nil
        }
    }

    // MARK: - 배경 이미지

    var backgroundImage: UIImage? {
        switch self {
        case .working:  return UIImage(resource: .Image.imgWorkingBg)
        case .vacation: return UIImage(resource: .Image.imgVacationBg)
        case .finished: return UIImage(resource: .Image.imgFinishBg)
        default:        return nil
        }
    }

    // MARK: - 서브타이틀 (finished 전용)

    var subtitleText: String? {
        guard self == .finished else { return nil }
        return "이번달 누적 월급"
    }

    // MARK: - 안내 메시지 (offline / lowPower 전용)

    var infoMessage: String? {
        switch self {
        case .offline:  return "네트워크 연결 상태가\n좋지 않습니다"
        case .lowPower: return "절전모드 해제 후\n사용해 주세요"
        default:        return nil
        }
    }
    
    var buttonText: String? {
        switch self {
        case .offline:  return "새로고침"
        case .lowPower: return "앱 실행"
        default:        return nil
        }
    }
}
