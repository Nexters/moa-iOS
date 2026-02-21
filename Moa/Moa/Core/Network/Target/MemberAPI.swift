//
//  MemberAPI.swift
//  Moa
//
//  Created by mirim on 2/21/26.
//

import Foundation
import Moya
import Alamofire

enum MemberAPI {
    case getMember
}

extension MemberAPI: TargetType {
    var baseURL: URL {
        URL(string: "http://139.150.10.57:8080")!
    }

    var path: String {
        switch self {
        case .getMember:
            return "/api/v1/member"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getMember:
            return .get
        }
    }

    var task: Moya.Task {
        switch self {
        case .getMember:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        nil
    }
}
