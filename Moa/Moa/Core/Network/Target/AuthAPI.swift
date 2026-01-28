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
    case checkLogin
}

extension AuthAPI: TargetType {

    // MARK: - Base URL
    var baseURL: URL {
        URL(string: "https://test.com")!        // TODO: URL 교체 필요
    }

    // MARK: - Path
    var path: String {
        switch self {
        case .checkLogin:
            return "/auth/status"               // TODO: URL 교체 필요
        }
    }

    // MARK: - Method
    var method: Moya.Method {
        switch self {
        case .checkLogin:
            return .get
        }
    }

    // MARK: - Task
    var task: Moya.Task {
        .requestPlain
    }

    // MARK: - Headers
    var headers: [String: String]? {
        nil
    }

    // MARK: - Sample Data (Stub / Test)
    var sampleData: Data {
        switch self {
        case .checkLogin:
            return """
            {
              "isLoggedIn": true
            }
            """.data(using: .utf8)!
        }
    }
}
