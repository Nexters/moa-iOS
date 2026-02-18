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
    
    func generateRandomNickname() -> String {
        repository.generateRandomNickname()
    }
    
    func updateNickname(to nickname: String) async throws -> ProfileEntity {
        try await repository.updateNickname(to: nickname)
    }
    
    func updatePayroll(type: SalaryType, amount: Int) async throws -> PayrollEntity {
        try await repository.updatePayroll(type: type, amount: amount)
    }
    
    func updateWorkPolicy(selectedWeekdays: [Weekday], clockInTime: String, clockOutTime: String) async throws -> WorkPolicyEntity {
        try await repository.updateWorkPolicy(selectedWeekdays: selectedWeekdays, clockInTime: clockInTime, clockOutTime: clockOutTime)
    }
}
