//
//  APIError.swift
//  Moa
//
//  Created by 정도현 on 1/26/26.
//

import Moya

enum APIError: Error {
    case network(MoyaError)       // Moya 내부 에러 처리
    case decoding(Error)          // Decoding Failure
    case httpStatus(Int)          // HTTP 상태 코드 처리
    case server(code: String, message: String, fieldErrors: [FieldError]?) // 서버 표준 에러
    case unknown                  // unknown
}

struct FieldError: Decodable {
    let field: String
    let message: String
}

enum DomainError: Error {
    case missingRequiredData
}
