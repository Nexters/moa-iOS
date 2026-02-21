//
//  WorkPolicyAPI.swift
//  Moa
//
//  Created by mirim on 2/21/26.
//

import Foundation
import Moya
import Alamofire

enum WorkPolicyAPI {
    case getWorkPolicy
    case updateWorkPolicy(WorkPolicyUpsertRequest)
}

extension WorkPolicyAPI: TargetType {
    
    var baseURL: URL {
        URL(string: "http://139.150.10.57:8080")!
    }
    
    var path: String {
        switch self {
        case .getWorkPolicy:
            "/api/v1/profile"
        case .updateWorkPolicy:
            "/api/v1/profile/nickname"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getWorkPolicy: .get
        case .updateWorkPolicy: .patch
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getWorkPolicy:
            return .requestPlain
        case let .updateWorkPolicy(body):
            return .requestJSONEncodable(body)
        }
    }
    
    var headers: [String : String]? {
        nil
    }
}
