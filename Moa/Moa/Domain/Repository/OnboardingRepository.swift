//
//  OnboardingRepository.swift
//  Moa
//
//  Created by mirim on 2/16/26.
//

import Foundation

protocol OnboardingRepository {
    func fetchOnboardingStatus() async throws -> OnboardingStatusEntity
    func generateRandomNickname() -> String
    func updateNickname(to nickname: String) async throws -> ProfileEntity // 리턴값 필요할지
}
