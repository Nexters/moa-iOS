//
//  ProfileAPI.swift
//  Moa
//
//  Created by mirim on 2/19/26.
//

import Foundation
import Moya
import Alamofire

enum ProfileAPI {
    case getProfile
    case updateNickname(ProfileUpsertRequest)
    case updatePayday
    case updateWorkplace
}

extension ProfileAPI: TargetType {
    
    var baseURL: URL {
        URL(string: "http://139.150.10.57:8080")!
    }
    
    var path: String {
        switch self {
        case .getProfile:
            "/api/v1/profile"
        case .updateNickname:
            "/api/v1/profile/nickname"
        case .updatePayday:
            "/api/v1/profile/payday"
        case .updateWorkplace:
            "/api/v1/profile/workplace"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getProfile: .get
        case .updateNickname: .patch
        case .updatePayday: .patch
        case .updateWorkplace: .patch
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getProfile:
            return .requestPlain
        case let .updateNickname(body):
            return .requestJSONEncodable(body)
        case .updatePayday:
            return .requestPlain
        case .updateWorkplace:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        nil
    }
}
