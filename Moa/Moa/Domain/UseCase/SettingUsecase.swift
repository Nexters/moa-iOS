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
    private let fcmRepository: FcmRepository
    
    private let userDefaults: UserDefaults
    
    init(
        profileRepository: ProfileRepository,
        memberRepository: MemberRepository,
        payrollRepository: PayrollRepository,
        workPolicyRepository: WorkPolicyRepository,
        onboardingRepository: OnboardingRepository,
        notificationSettingRepository: NotificationSettingRepository,
        versionRepository: VersionRepository,
        authRepository: AuthRepository,
        fcmRepository: FcmRepository,
        userDefaults: UserDefaults = .standard
    ) {
        self.profileRepository = profileRepository
        self.memberRepository = memberRepository
        self.payrollRepository = payrollRepository
        self.workPolicyRepository = workPolicyRepository
        self.onboardingRepository = onboardingRepository
        self.notificationSettingRepository = notificationSettingRepository
        self.versionRepository = versionRepository
        self.authRepository = authRepository
        self.fcmRepository = fcmRepository
        self.userDefaults = userDefaults
    }
    
    func getProfile() async throws -> ProfileEntity {
        let result = try await profileRepository.getProfile()
        userDefaults.set(result.paydayDay, forKey: "payday")
        
        return result
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
        let result = try await profileRepository.updatePayday(to: payday)
        userDefaults.set(result.paydayDay, forKey: "payday")
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
        if let fcmToken = AuthSessionManager.shared.currentFcmToken() {
            await fcmRepository.deleteFcmToken(fcmToken: fcmToken)
        }
        
        AuthSessionManager.shared.clearTokens()
        
        userDefaults.removeObject(forKey: "payday")
        userDefaults.removeObject(forKey: "HasShownWorkAlarmSheet")
    }
    
    func withdrawal(reason: [String]) async throws {
        try await memberRepository.withdrawal(reason: reason)
    }
}
