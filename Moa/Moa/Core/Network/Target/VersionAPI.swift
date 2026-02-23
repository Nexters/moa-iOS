//
//  VersionAPI.swift
//  Moa
//
//  Created by mirim on 2/22/26.
//

import Foundation
import Moya
import Alamofire

enum VersionAPI {
    case getVersion(String)
}

extension VersionAPI: TargetType {

    var baseURL: URL {
        URL(string: "http://139.150.10.57:8080")!
    }

    var path: String {
        switch self {
        case .getVersion: "/api/v1/version"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getVersion:
            return .get
        }
    }

    var task: Moya.Task {
        switch self {
        case let .getVersion(osType):
            return .requestParameters(
                parameters: ["osType": osType],
                encoding: URLEncoding.queryString
            )
        }
    }

    var headers: [String: String]? {
        nil
    }
}

