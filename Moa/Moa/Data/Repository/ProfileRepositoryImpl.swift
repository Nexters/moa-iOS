//
//  ProfileRepositoryImpl.swift
//  Moa
//
//  Created by mirim on 2/19/26.
//

import Foundation

final class ProfileRepositoryImpl: ProfileRepository {
    private let apiClient: APIClient
    
    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    
    func getProfile() async throws -> ProfileEntity {
        let response: ProfileResponse = try await apiClient.request(
            ProfileAPI.getProfile
        )
        
        return response.toDomain()
    }
    
    func updateNickname(to nickname: String?) async throws {
        guard let nickname else { return }
        let request = ProfileUpsertRequest(nickname: nickname)
        let _: ProfileResponse = try await apiClient.request(
            ProfileAPI.updateNickname(request)
        )
    }
    
    func updateWorkplace(to workplace: String) async throws {
        let request = WorkplaceUpdateRequest(workplace: workplace)
        let _: ProfileResponse = try await apiClient.request(ProfileAPI.updateWorkplace(request))
    }
}
