//
//  HomeAPI.swift
//  Moa
//
//  Created by 정도현 on 2/22/26.
//

import Foundation
import Moya
import Alamofire

enum HomeAPI {
    case getData
}

extension HomeAPI: TargetType {
    var baseURL: URL {
        URL(string: Config.getPropertyValue(.baseURL))!
    }

    var path: String {
        switch self {
        case .getData:
            return "/api/v1/home"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getData:
            return .get
        }
    }

    var task: Moya.Task {
        switch self {
        case .getData:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        nil
    }
}
