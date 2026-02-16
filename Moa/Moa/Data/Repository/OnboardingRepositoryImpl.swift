//
//  OnboardingRepositoryImpl.swift
//  Moa
//
//  Created by mirim on 2/16/26.
//

import Foundation

final class OnboardingRepositoryImpl: OnboardingRepository {
    private let apiClient: APIClient
    
    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    
    func fetchOnboardingStatus() async throws -> OnboardingStatusEntity {
        let response: OnboardingStatusResponse = try await apiClient.request(
            OnboardingAPI.getOnboardingStatus
        )
        
        return response.toDomain()
    }
}
