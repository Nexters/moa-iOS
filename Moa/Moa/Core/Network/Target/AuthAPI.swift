//
//  AuthAPI.swift
//  Moa
//
//  Created by 정도현 on 1/26/26.
//

import Foundation
import Moya
import Alamofire

enum AuthAPI {
    case kakaoAuth(SocialLoginRequest)
    case appleAuth(SocialLoginRequest)
    case logout(LogoutRequest)
}

extension AuthAPI: TargetType {

    var baseURL: URL {
        URL(string: "http://139.150.10.57:8080")!
    }

    var path: String {
        switch self {
        case .kakaoAuth:
            return "/api/v1/auth/kakao"
            
        case .appleAuth:
            return "/api/v1/auth/apple"
            
        case .logout:
            return "/api/v1/auth/logout"
        }
    }

    var method: Moya.Method {
        switch self {
        case .kakaoAuth:
            return .post
            
        case .appleAuth:
            return .post
            
        case .logout:
            return .post
        }
    }

    var task: Moya.Task {
        switch self {
        case let .kakaoAuth(body):
            return .requestJSONEncodable(body)
            
        case let .appleAuth(body):
            return .requestJSONEncodable(body)
            
        case let .logout(body):
            return .requestJSONEncodable(body)
        }
    }

    var headers: [String: String]? {
        nil
    }

    var sampleData: Data {
        switch self {
        default:
            return """
            {
              "isLoggedIn": true
            }
            """.data(using: .utf8)!
        }
    }
}
