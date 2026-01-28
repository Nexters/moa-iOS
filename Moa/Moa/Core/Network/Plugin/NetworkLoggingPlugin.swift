//
//  NetworkLoggingPlugin.swift
//  Moa
//
//  Created by 정도현 on 1/26/26.
//

import Foundation
import Moya

final class NetworkLoggingPlugin: PluginType {

    func willSend(_ request: RequestType, target: TargetType) {
        #if DEBUG
        print("➡️ [REQUEST]")
        print("URL:", request.request?.url?.absoluteString ?? "")
        print("METHOD:", request.request?.httpMethod ?? "")
        print("HEADERS:", request.request?.allHTTPHeaderFields ?? [:])
        print("BODY:", String(data: request.request?.httpBody ?? Data(), encoding: .utf8) ?? "")
        #endif
    }

    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        #if DEBUG
        print("⬅️ [RESPONSE]")
        switch result {
        case .success(let response):
            print("STATUS:", response.statusCode)
            print("DATA:", String(data: response.data, encoding: .utf8) ?? "")
        case .failure(let error):
            print("ERROR:", error)
        }
        #endif
    }
}
