//
//  MemberResponse.swift
//  Moa
//
//  Created by mirim on 2/21/26.
//

import Foundation

struct MemberResponse: Decodable {
    let id: Int?
    let provider: String? // Enum ("KAKAO" / "APPLE")
    
    func toDomain() -> MemberEntity {
        .init(
            provider: toAccountprovider(raw: provider)
        )
    }
    
    private func toAccountprovider(raw: String?) -> AccountProvider {
        switch raw?.uppercased() {
        case "APPLE": .apple
        default: .kakao
        }
    }
}
