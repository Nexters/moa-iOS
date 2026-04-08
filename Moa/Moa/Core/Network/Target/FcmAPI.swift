//
//  FcmAPI.swift
//  Moa
//
//  Created by mirim on 2/24/26.
//

import Foundation
import Moya
import Alamofire

enum FcmAPI {
    case updateFcmToken(FcmTokenRequest)
    case deleteFcmToken(FcmTokenRequest)
}

extension FcmAPI: TargetType {
    var baseURL: URL {
        URL(string: Config.getPropertyValue(.baseURL))!
    }

    var path: String {
        switch self {
        case .updateFcmToken:
            return "/api/v1/fcm/token"
        case .deleteFcmToken:
            return "/api/v1/fcm/token"
        }
    }

    var method: Moya.Method {
        switch self {
        case .updateFcmToken:
            return .put
        case .deleteFcmToken:
            return .delete
        }
    }

    var task: Moya.Task {
        switch self {
        case let .updateFcmToken(body):
            return .requestJSONEncodable(body)
        case let .deleteFcmToken(body):
            return .requestJSONEncodable(body)
        }
    }

    var headers: [String: String]? {
        nil
    }
}
