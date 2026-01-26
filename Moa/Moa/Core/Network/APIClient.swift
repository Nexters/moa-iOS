//
//  APIClient.swift
//  Moa
//
//  Created by 정도현 on 1/26/26.
//

import Combine
import Moya

/// 네트워크 요청에 대한 추상화 인터페이스
protocol APIClient {
    func request<T: Decodable>(_ target: TargetType) -> AnyPublisher<T, APIError>
}
