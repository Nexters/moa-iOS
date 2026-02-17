//
//  OnboardingUsecase.swift
//  Moa
//
//  Created by mirim on 2/16/26.
//

import Foundation

final class OnboardingUsecase {
    private let repository: OnboardingRepository
    
    init(repository: OnboardingRepository) {
        self.repository = repository
    }
    
    func getOnboardingStatus() async throws -> OnboardingStatusEntity {
        try await repository.fetchOnboardingStatus()
    }
}
