//
//  OnboardingStatusEntity.swift
//  Moa
//
//  Created by mirim on 2/16/26.
//

import Foundation

struct OnboardingStatusEntity {
    let profile: ProfileEntity?
    let payroll: PayrollEntity?
    let workPolicy: WorkPolicyEntity?
    let hasRequiredTermsAgreed: Bool
}

struct ProfileEntity {
    let nickname: String?
    let workplace: String?
}

struct PayrollEntity {
    let salaryInputType: SalaryType
    let salaryAmount: Int?
    let paydayDay: Int?
}

struct WorkPolicyEntity {
    let workdays: [Weekday]
    let clockInTime: String?
    let clockOutTime: String?
}
