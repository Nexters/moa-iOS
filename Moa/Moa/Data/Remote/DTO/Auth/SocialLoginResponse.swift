//
//  SocialLoginResponse.swift
//  Moa
//
//  Created by mirim on 2/11/26.
//

import Foundation

struct SocialLoginResponse: Decodable {
    let userId: Int
    let accessToken: String
    
    func toDomain() -> SocialLoginEntity {
        .init(
            userId: userId,
            accessToken: accessToken
        )
    }
}
