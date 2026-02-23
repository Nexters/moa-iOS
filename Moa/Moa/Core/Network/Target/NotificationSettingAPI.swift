//
//  NotificationSettingAPI.swift
//  Moa
//
//  Created by mirim on 2/24/26.
//

import Foundation
import Moya
import Alamofire

enum NotificationSettingAPI {
    case getNotification
    case updateNotification(NotificationSettingUpdateRequest)
}

extension NotificationSettingAPI: TargetType {
    var baseURL: URL {
        URL(string: "http://139.150.10.57:8080")!
    }

    var path: String {
        switch self {
        case .getNotification:
            return "/api/v1/settings/notification"
        case .updateNotification:
            return "/api/v1/settings/notification"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getNotification:
            return .get
        case .updateNotification:
            return .patch
        }
    }

    var task: Moya.Task {
        switch self {
        case .getNotification:
            return .requestPlain
        case let .updateNotification(body):
            return .requestJSONEncodable(body)
        }
    }

    var headers: [String: String]? {
        nil
    }
}
