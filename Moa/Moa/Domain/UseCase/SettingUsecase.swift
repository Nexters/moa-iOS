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
    private let notificationSettingRepository: NotificationSettingRepository
    private let versionRepository: VersionRepository
    private let authRepository: AuthRepository
    
    init(
        profileRepository: ProfileRepository,
        memberRepository: MemberRepository,
        payrollRepository: PayrollRepository,
        workPolicyRepository: WorkPolicyRepository,
        onboardingRepository: OnboardingRepository,
        notificationSettingRepository: NotificationSettingRepository,
        versionRepository: VersionRepository,
        authRepository: AuthRepository
    ) {
        self.profileRepository = profileRepository
        self.memberRepository = memberRepository
        self.payrollRepository = payrollRepository
        self.workPolicyRepository = workPolicyRepository
        self.onboardingRepository = onboardingRepository
        self.notificationSettingRepository = notificationSettingRepository
        self.versionRepository = versionRepository
        self.authRepository = authRepository
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
    
    func getNotificationSettings() async throws -> [NotificationSettingEntity] {
        try await notificationSettingRepository.getNotificationList()
    }
    
    func updateNotificationSettings(type: String, checked: Bool) async throws -> [NotificationSettingEntity] {
        try await notificationSettingRepository.updateNotificationSetting(type: type, checked: checked)
    }
    
    func getVersionInfo() async throws -> VersionEntity {
        try await versionRepository.getVersionInfo()
    }
    
    func logout(fcmDeviceToken: String) async throws {
        try await authRepository.logout(fcmDeviceToken: fcmDeviceToken)
    }
}
