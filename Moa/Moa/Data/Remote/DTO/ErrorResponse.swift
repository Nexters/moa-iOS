//
//  ErrorResponse.swift
//  Moa
//
//  Created by mirim on 2/11/26.
//

import Foundation

/// 디폴트 에러 리스폰스
struct ErrorResponse: Decodable {
    let code: String
    let message: String
    let fieldErrors: [FieldError]?
        
    enum CodingKeys: String, CodingKey {
        case code, message
        case fieldErrors = "content"
    }
}
