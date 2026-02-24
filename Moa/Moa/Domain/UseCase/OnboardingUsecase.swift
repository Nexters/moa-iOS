//
//  OnboardingUsecase.swift
//  Moa
//
//  Created by mirim on 2/16/26.
//

import Foundation

final class OnboardingUsecase {
    private let onboardingRepository: OnboardingRepository
    private let authRepository: AuthRepository
    
    init(
        onboardingRepository: OnboardingRepository,
        authRepository: AuthRepository
    ) {
        self.onboardingRepository = onboardingRepository
        self.authRepository = authRepository
    }
    
    func getOnboardingStatus() async throws -> OnboardingStatusEntity {
        try await onboardingRepository.fetchOnboardingStatus()
    }
    
    func generateRandomNickname() -> String {
        onboardingRepository.generateRandomNickname()
    }
    
    func updateNickname(to nickname: String) async throws -> ProfileEntity {
        try await onboardingRepository.updateNickname(to: nickname)
    }
    
    func updatePayroll(type: SalaryType, amount: Int) async throws -> PayrollEntity {
        try await onboardingRepository.updatePayroll(type: type, amount: amount)
    }
    
    func updateWorkPolicy(selectedWeekdays: [Weekday], clockInTime: TimeIndicatorEntity, clockOutTime: TimeIndicatorEntity) async throws -> WorkPolicyEntity {
        try await onboardingRepository.updateWorkPolicy(selectedWeekdays: selectedWeekdays, clockInTime: clockInTime, clockOutTime: clockOutTime)
    }
    
    func getTerms() async throws -> [TermsEntity] {
        try await onboardingRepository.fetchTerms()
    }
    
    func updateTermsAgreement(to agreements: [AgreementEntity]) async throws -> TermsAgreementEntity {
        try await onboardingRepository.updateTermsAgreement(to: agreements)
    }
}
