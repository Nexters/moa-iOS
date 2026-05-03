//
//  AnalyticsUserProperty.swift
//  Moa
//
//  Created by mirim on 5/3/26.
//

import Foundation

/// 유저 속성 - Analytics.identify(_:)로 전송
enum AnalyticsUserProperty {
    /// 홈 진입시 마다 알림 권한 상태 트래킹
    case notificationPermission(Bool)
    
    var properties: [String: Any] {
        switch self {
        case let .notificationPermission(isGranted):
            return ["notification_permission": isGranted]
        }
    }
}
