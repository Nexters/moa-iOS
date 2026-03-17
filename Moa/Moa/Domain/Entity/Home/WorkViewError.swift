//
//  WorkViewError.swift
//  Moa
//
//  Created by 정도현 on 3/17/26.
//

import Foundation

enum WorkViewError: LocalizedError, Equatable {
    case network
    case dataCorrupted
    case unauthorized
    case invalidWorkTime
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .network:          return "네트워크 연결을 확인해주세요."
        case .dataCorrupted:    return "데이터를 처리하는 중 문제가 발생했습니다."
        case .unauthorized:     return "로그인이 필요합니다."
        case .invalidWorkTime:  return "종료 시간이 시작 시간보다 빨라요."
        case .unknown(let msg): return msg
        }
    }
}
