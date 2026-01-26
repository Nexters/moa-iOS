//
//  MoyaPlugin.swift
//  Moa
//
//  Created by 정도현 on 1/26/26.
//

import Foundation
import Moya

/// Authorization의 Header 자동 주입
final class MoyaPlugin: PluginType {
    private let tokenProvider: () -> String?

    init(tokenProvider: @escaping () -> String?) {
        self.tokenProvider = tokenProvider
    }

    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var request = request
        
        // 토큰이 없다면 원본 요청 반환
        guard let token = tokenProvider() else { return request }

        // Authroization 헤더 추가
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
