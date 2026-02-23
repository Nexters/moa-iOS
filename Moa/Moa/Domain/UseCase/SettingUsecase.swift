//
//  SettingUsecase.swift
//  Moa
//
//  Created by mirim on 2/19/26.
//

import Foundation

final class SettingUsecase {
    private let profileRepository: ProfileRepository
    private let memberRepository: MemberRepository
    private let payrollRepository: PayrollRepository
    private let workPolicyRepository: WorkPolicyRepository
    private let onboardingRepository: OnboardingRepository
    
    init(
        profileRepository: ProfileRepository,
        memberRepository: MemberRepository,
        payrollRepository: PayrollRepository,
        workPolicyRepository: WorkPolicyRepository,
        onboardingRepository: OnboardingRepository
    ) {
        self.profileRepository = profileRepository
        self.memberRepository = memberRepository
        self.payrollRepository = payrollRepository
        self.workPolicyRepository = workPolicyRepository
        self.onboardingRepository = onboardingRepository
    }
    
    func getProfile() async throws -> ProfileEntity {
        try await profileRepository.getProfile()
    }
    
    func updateNickname(to nickname: String?) async throws {
        try await profileRepository.updateNickname(to: nickname)
    }
    
    func getMember() async throws -> MemberEntity {
        try await memberRepository.getMember()
    }
    
    func getPayroll() async throws -> PayrollEntity {
        try await payrollRepository.getPayroll()
    }
    
    func updatePayroll(salaryType: SalaryType, amount: Int) async throws -> PayrollEntity {
        try await payrollRepository.updatePayroll(salaryInputType: salaryType, salaryAmount: amount)
    }
    
    func getWorkPolicy() async throws -> WorkPolicyEntity {
        try await workPolicyRepository.getWorkPolicy()
    }
    
    func updateWorkPolicy(weekdays: [Weekday], clockInTime: TimeIndicatorEntity, clockOutTime: TimeIndicatorEntity) async throws -> WorkPolicyEntity {
        try await workPolicyRepository.updateWorkPolicy(
            weekdays: weekdays,
            clockInTime: clockInTime,
            clockOutTime: clockOutTime
        )
    }
    
    func updateWorkplace(to workplace: String) async throws {
        try await workPolicyRepository.updateWorkplace(to: workplace)
    }
    
    func getTerms() async throws -> [TermsEntity] {
        try await onboardingRepository.fetchTerms()
    }
    
    func updatePayday(to payday: Int) async throws {
        try await profileRepository.updatePayday(to: payday)
    }
}
