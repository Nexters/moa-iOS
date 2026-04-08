//
//  PayrollAPI.swift
//  Moa
//
//  Created by mirim on 2/21/26.
//

import Foundation
import Moya
import Alamofire

enum PayrollAPI {
    case getPayroll
    case updatePayroll(PayrollUpsertRequest)
}

extension PayrollAPI: TargetType {
    
    var baseURL: URL {
        URL(string: Config.getPropertyValue(.baseURL))!
    }
    
    var path: String {
        switch self {
        case .getPayroll:
            "/api/v1/payroll"
        case .updatePayroll:
            "/api/v1/payroll"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getPayroll: .get
        case .updatePayroll: .patch
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getPayroll:
            return .requestPlain
        case let .updatePayroll(body):
            return .requestJSONEncodable(body)
        }
    }
    
    var headers: [String : String]? {
        nil
    }
}
