//
//  VersionResponse.swift
//  Moa
//
//  Created by mirim on 2/22/26.
//

import Foundation

struct VersionResponse: Decodable {
    let latestVersion: String
    let minimumVersion: String
    
    func toDomain() -> VersionEntity {
        .init(
            latestVersion: latestVersion,
            minimumVersion: minimumVersion
        )
    }
}
