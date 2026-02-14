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

    func request<T: Decodable>(_ target: TargetType) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            provider.request(MultiTarget(target)) { result in
                switch result {
                case let .success(response):
                    do {
                        // HTTP 상태 코드 체크
                        guard (200..<300).contains(response.statusCode) else {
                            // 4xx, 5xx 에러 응답 파싱 시도
                            if let errorResponse = try? JSONDecoder().decode(
                                ErrorResponse.self,
                                from: response.data
                            ) {
                                throw APIError.server(
                                    code: errorResponse.code,
                                    message: errorResponse.message,
                                    fieldErrors: errorResponse.fieldErrors
                                )
                            }
                            throw APIError.httpStatus(response.statusCode)
                        }
                        
                        // 정상 응답 파싱
                        let decoded = try JSONDecoder().decode(
                            BaseResponse<T>.self,
                            from: response.data
                        )
                        
                        continuation.resume(returning: decoded.content)
                    } catch {
                        if let apiError = error as? APIError {
                            continuation.resume(throwing: apiError)
                        } else {
                            continuation.resume(throwing: error)
                        }
                    }
                    
                case let .failure(error):
                    if let errorData = error.response?.data,
                       let serverError = try? JSONDecoder().decode(ErrorResponse.self, from: errorData) {
                        continuation.resume(
                            throwing: APIError.server(
                                code: serverError.code,
                                message: serverError.message,
                                fieldErrors: serverError.fieldErrors
                            )
                        )
                    } else {
                        continuation.resume(throwing: APIError.network(error))
                    }
                }
            }
        }
    }
}
