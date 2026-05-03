//
//  AnalyticsUserProperty.swift
//  Moa
//
//  Created by mirim on 5/3/26.
//

import Foundation

/// 유저 속성 - Analytics.identify(_:)로 전송
enum AnalyticsUserProperty {
    case notificationPermission(Bool)
    
    var properties: [String: Any] {
        switch self {
        case let .notificationPermission(isGranted):
            return ["notification_permission": isGranted]
        }
    }
}
