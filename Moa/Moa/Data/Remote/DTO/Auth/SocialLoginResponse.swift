//
//  SocialLoginResponse.swift
//  Moa
//
//  Created by mirim on 2/11/26.
//

import Foundation

struct SocialLoginResponse: Decodable {
    let accessToken: String
    
    func toDomain() -> SocialLoginEntity {
        .init(accessToken: accessToken)
    }
}
