//
//  PayrollWorkPolicyViewModel.swift
//  Moa
//
//  Created by mirim on 2/21/26.
//

import Foundation

enum PayrollWorkPolicyOutput {
    case payrollFetched
    case workPolicyFetched
    case profileFetched
}

final class PayrollWorkPolicyInfoViewModel: BaseViewModel<PayrollWorkPolicyOutput> {
    
    // MARK: - Constants
    
    private enum Constants {
        static let unregistered = "미등록"
    }
    
    // MARK: - Dependencies
    
    let accountProvider: AccountProvider
    private let settingUsecase: SettingUsecase
    
    // MARK: - Properties
    
    // 월급 정보
    private(set) var salary: String = ""
    private(set) var payday: String = ""
    private(set) var salaryType: SalaryType = .annual
    private(set) var salaryAmount: Int?
    
    // 근무 정보
    private(set) var currentWorkplace: String?
    private(set) var workplaceDisplayText: String = ""
    private(set) var workingDays: String = ""
    private(set) var workingHours: String = ""
    
    // MARK: - Init
    
    init(
        accountProvider: AccountProvider,
        settingUsecase: SettingUsecase
    ) {
        self.accountProvider = accountProvider
        self.settingUsecase = settingUsecase
    }
    
    func getInfo() {
        Task {
            async let profile: Void = getProfile()
            async let payroll: Void = getPayroll()
            async let workPolicy: Void = getWorkPolicy()
            
            _ = try await (profile, payroll, workPolicy)
        }
    }
    
    private func getPayroll() async throws {
        let payroll = try await settingUsecase.getPayroll()
        await MainActor.run {
            let salaryType = "\(payroll.salaryInputType.displayName) · "
            let salaryAmount = AppNumberFormatter.koreanCurrencyText(for: payroll.salaryAmount ?? 0)
            
            self.salary = salaryType + salaryAmount
            self.salaryType = payroll.salaryInputType
            self.salaryAmount = payroll.salaryAmount
            self.send(.payrollFetched)
        }
    }
    
    private func getWorkPolicy() async throws {
        let workPolicy = try await settingUsecase.getWorkPolicy()
        await MainActor.run {
            let workingDays = workPolicy.workdays.map({ $0.displayName })
            if !workingDays.isEmpty {
                self.workingDays = workingDays.joined(separator: ", ")
            } else {
                self.workingDays = Constants.unregistered
            }
            
            if let clockInTime = workPolicy.clockInTime,
               let clockOutTime = workPolicy.clockOutTime {
                self.workingHours = "\(clockInTime.displayString)~\(clockOutTime.displayString)"
            } else {
                self.workingHours = Constants.unregistered
            }
            
            self.send(.workPolicyFetched)
        }
    }
    
    private func getProfile() async throws {
        let profile = try await settingUsecase.getProfile()
        await MainActor.run {
            if let payday = profile.paydayDay {
                self.payday = "\(payday)일"
            } else {
                self.payday = Constants.unregistered
            }
            
            currentWorkplace = profile.workplace
            
            if let workplace = profile.workplace {
                self.workplaceDisplayText = workplace
            } else {
                self.workplaceDisplayText = Constants.unregistered
            }
            
            self.send(.profileFetched)
        }
    }
}
