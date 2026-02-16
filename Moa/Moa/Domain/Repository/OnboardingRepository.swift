//
//  OnboardingRepository.swift
//  Moa
//
//  Created by mirim on 2/16/26.
//

import Foundation

protocol OnboardingRepository {
    func fetchOnboardingStatus() async throws -> OnboardingStatusEntity
}
