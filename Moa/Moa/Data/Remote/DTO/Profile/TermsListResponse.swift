//
//  TermsListResponse.swift
//  Moa
//
//  Created by mirim on 2/18/26.
//

import Foundation

struct TermsListResponse: Decodable {
    let terms: [TermsContentResponse]
}

struct TermsContentResponse: Decodable {
    let code: String?
    let title: String?
    let required: Bool?
    let contentUrl: String?
    
    func toDomain() -> TermsEntity {
        .init(
            code: code,
            title: title ?? "",
            required: required ?? false,
            contentUrl: contentUrl
        )
    }
}
