//
//  MoyaAPIClient.swift
//  Moa
//
//  Created by 정도현 on 1/26/26.
//

import Foundation
import Combine
import CombineMoya
import Moya

/// Moya 기반 APIClient 구현체
final class MoyaAPIClient: APIClient {
    private let provider: MoyaProvider<MultiTarget>

    init(provider: MoyaProvider<MultiTarget> = .init()) {
        self.provider = provider
    }

    func request<T: Decodable>(_ target: TargetType) -> AnyPublisher<T, APIError> {
        provider.requestPublisher(MultiTarget(target))
            .mapError { APIError.network($0) }
            .tryMap { response in
                guard (200..<300).contains(response.statusCode) else {
                    throw APIError.server(response.statusCode)
                }
                return response.data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError {
                ($0 as? APIError) ?? APIError.decoding($0)
            }
            .eraseToAnyPublisher()
    }
}
