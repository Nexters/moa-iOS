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
    
    init(
        profileRepository: ProfileRepository,
        memberRepository: MemberRepository,
        payrollRepository: PayrollRepository,
        workPolicyRepository: WorkPolicyRepository
    ) {
        self.profileRepository = profileRepository
        self.memberRepository = memberRepository
        self.payrollRepository = payrollRepository
        self.workPolicyRepository = workPolicyRepository
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
    
    func updateWorkPolicy(weekdays: [Weekday], clockInTime: String?, clockOutTime: String?) async throws -> WorkPolicyEntity {
        try await workPolicyRepository.updateWorkPolicy(
            weekdays: weekdays,
            clockInTime: clockInTime,
            clockOutTime: clockOutTime
        )
    }
    
    func updateWorkplace(to workplace: String) async throws {
        try await workPolicyRepository.updateWorkplace(to: workplace)
    }
}
