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
    case server(Int)              // HTTP 상태 코드 처리
    case unknown                  // unknown
}
