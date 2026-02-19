//
//  TermsAgreementResponse.swift
//  Moa
//
//  Created by mirim on 2/18/26.
//

import Foundation

struct TermsAgreementResponse: Decodable {
    let agreements: [AgreementResponse]?
    let hasRequiredTermsAgreed: Bool?
    
    func toDomain() -> TermsAgreementEntity {
        .init(
            agreements: agreements?.compactMap { $0.toDomain() } ?? [],
            hasRequiredTermsAgreed: hasRequiredTermsAgreed ?? false
        )
    }
}

struct AgreementResponse: Decodable {
    let code: String?
    let agreed: Bool?
    
    func toDomain() -> AgreementEntity {
        .init(
            code: code,
            agreed: agreed ?? false
        )
    }
}
