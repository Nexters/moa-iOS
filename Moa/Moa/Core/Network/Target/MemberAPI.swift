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
    case withdrawal(WithdrawalRequest)
}

extension MemberAPI: TargetType {
    var baseURL: URL {
        URL(string: Config.getPropertyValue(.baseURL))!
    }

    var path: String {
        switch self {
        case .getMember:
            return "/api/v1/member"
        case .withdrawal:
            return "/api/v1/member/withdrawal"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getMember:
            return .get
        case .withdrawal:
            return .post
        }
    }

    var task: Moya.Task {
        switch self {
        case .getMember:
            return .requestPlain
        case let .withdrawal(body):
            return .requestJSONEncodable(body)
        }
    }

    var headers: [String: String]? {
        nil
    }
}
