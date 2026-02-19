//
//  BaseResponse.swift
//  Moa
//
//  Created by mirim on 2/11/26.
//

import Foundation

/// 디폴트 성공 리스폰스
struct BaseResponse<T: Decodable>: Decodable {
    let code: String
    let message: String
    let content: T
}
