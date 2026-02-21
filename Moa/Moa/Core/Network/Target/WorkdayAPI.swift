//
//  WorkdayAPI.swift
//  Moa
//
//  Created by 정도현 on 2/21/26.
//

import Foundation
import Moya
import Alamofire

enum WorkdayAPI {
    case getWorkday(date: String)
    case updateWorkdayAll(date: String, body: WorkdayUpdateRequest)
    case updateWorkdayClockEnd(date: String, body: ClockEndRequest)
}

extension WorkdayAPI: TargetType {
    
    var baseURL: URL {
        URL(string: "http://139.150.10.57:8080")!
    }
    
    var path: String {
        switch self {
        case let .getWorkday(date):
            return "/api/v1/workdays/\(date)"
        case let .updateWorkdayAll(date, _):
            return "/api/v1/workdays/\(date)"
        case let .updateWorkdayClockEnd(date, _):
            return "/api/v1/workdays/\(date)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getWorkday:
            return .get
        case .updateWorkdayAll:
            return .put
        case .updateWorkdayClockEnd:
            return .patch
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getWorkday:
            return .requestPlain
        case let .updateWorkdayAll(_, body):
            return .requestJSONEncodable(body)
        case let .updateWorkdayClockEnd(_, body):
            return .requestJSONEncodable(body)
        }
    }
    
    var headers: [String : String]? {
        nil
    }
}
