//
//  TimeoutPlugin.swift
//  Moa
//
//  Created by 정도현 on 1/26/26.
//

import Foundation
import Moya

final class TimeoutPlugin: PluginType {

    private let timeout: TimeInterval

    init(timeout: TimeInterval) {
        self.timeout = timeout
    }

    func prepare(
        _ request: URLRequest,
        target: TargetType
    ) -> URLRequest {
        var request = request
        request.timeoutInterval = timeout
        return request
    }
}
