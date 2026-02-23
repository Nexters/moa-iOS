//
//  VersionRepositoryImpl.swift
//  Moa
//
//  Created by mirim on 2/24/26.
//

import Foundation

final class VersionRepositoryImpl: VersionRepository {
    private let apiClient: APIClient
    
    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    
    func getVersionInfo() async throws -> VersionEntity {
        let response: VersionResponse = try await apiClient.request(VersionAPI.getVersion("IOS"))
        
        return response.toDomain()
    }
}
