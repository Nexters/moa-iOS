//
//  VersionRepository.swift
//  Moa
//
//  Created by mirim on 2/24/26.
//

import Foundation

protocol VersionRepository {
    func getVersionInfo() async throws -> VersionEntity
}
