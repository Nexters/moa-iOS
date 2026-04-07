//
//  CalendarAPI.swift
//  Moa
//
//  Created by 정도현 on 3/30/26.
//

import Foundation
import Moya
import Alamofire

enum CalendarAPI {
    case getCalendarInfo(year: Int, month: Int)
}

extension CalendarAPI: TargetType {
    var baseURL: URL {
        URL(string: Config.getPropertyValue(.baseURL))!
    }

    var path: String {
        switch self {
        case .getCalendarInfo:
            return "/api/v1/calendar"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getCalendarInfo:
            return .get
        }
    }

    var task: Moya.Task {
        switch self {
        case let .getCalendarInfo(year, month):
            return .requestParameters(
                parameters: [
                    "year" : year,
                    "month" : month
                ],
                encoding: URLEncoding.queryString
            )
        }
    }

    var headers: [String: String]? {
        nil
    }
}
