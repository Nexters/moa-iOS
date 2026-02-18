//
//  ProfileResponse.swift
//  Moa
//
//  Created by mirim on 2/18/26.
//

import Foundation

struct ProfileResponse: Decodable {
    let nickname: String?
    let workplace: String?
    let paydayDay: Int?
    
    func toDomain() -> ProfileEntity {
        .init(
            nickname: nickname,
            workplace: workplace,
            paydayDay: paydayDay
        )
    }
}
