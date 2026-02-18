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
    func updateNickname(to nickname: String) async throws -> ProfileEntity
    func updatePayroll(type: SalaryType, amount: Int) async throws -> PayrollEntity
    func updateWorkPolicy(selectedWeekdays: [Weekday], clockInTime: TimeIndicatorEntity, clockOutTime: TimeIndicatorEntity) async throws -> WorkPolicyEntity
    func fetchTerms() async throws -> [TermsEntity]
    func updateTermsAgreement(to agreements: [AgreementEntity]) async throws -> TermsAgreementEntity
}
