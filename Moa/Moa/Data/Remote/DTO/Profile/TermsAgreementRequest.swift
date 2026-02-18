//
//  TermsAgreementRequest.swift
//  Moa
//
//  Created by mirim on 2/18/26.
//

import Foundation

struct TermsAgreementRequest: Encodable {
    let agreements: [AgreementItem]
    
    init(domain: [AgreementEntity]) {
        self.agreements = domain.compactMap { AgreementItem(domain: $0) }
    }
}

struct AgreementItem: Encodable {
    let code: String
    let agreed: Bool
    
    init?(domain: AgreementEntity) {
        guard let code = domain.code else { return nil }
        self.code = code
        self.agreed = domain.agreed
    }
}
