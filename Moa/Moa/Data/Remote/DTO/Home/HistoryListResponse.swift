//
//  HistoryListResponse.swift
//  Moa
//
//  Created by 정도현 on 2/22/26.
//

import Foundation

struct HistoryResponse: Decodable {
    let date: String
    let type: String
}

extension HistoryResponse {
    func toDomain() -> History {
        History(
            date: date,
            type: WorkdayType(rawValue: type) ?? .none
        )
    }
}
