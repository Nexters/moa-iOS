//
//  TermsAgreementEntity.swift
//  Moa
//
//  Created by mirim on 2/18/26.
//

import Foundation

struct TermsAgreementEntity {
    let agreements: [AgreementEntity]
    let hasRequiredTermsAgreed: Bool
}

struct AgreementEntity {
    let code: String?
    let agreed: Bool
}
