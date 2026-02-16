//
//  OnboardingStatusResponse.swift
//  Moa
//
//  Created by mirim on 2/16/26.
//

import Foundation

struct OnboardingStatusResponse: Decodable {
    let profile: ProfileResponse?
    let payroll: PayrollResponse?
    let workPolicy: WorkPolicyResponse?
    let hasRequiredTermsAgreed: Bool?
    
    func toDomain() -> OnboardingStatusEntity {
        .init(
            profile: profile?.toDomain(),
            payroll: payroll?.toDomain(),
            workPolicy: workPolicy?.toDomain(),
            hasRequiredTermsAgreed: hasRequiredTermsAgreed ?? false
        )
    }
}

struct ProfileResponse: Decodable {
    let nickname: String?
    let workplace: String?
    
    func toDomain() -> ProfileEntity {
        .init(
            nickname: nickname,
            workplace: workplace
        )
    }
}

struct PayrollResponse: Decodable {
    let effectiveFrom: String?
    let salaryInputType: String?
    let salaryAmount: Int?
    let paydayDay: Int?
    
    func toDomain() -> PayrollEntity {
        .init(
            salaryInputType: Self.mapSalaryType(salaryInputType),
            salaryAmount: salaryAmount,
            paydayDay: paydayDay
        )
    }
    
    private static func mapSalaryType(_ raw: String?) -> SalaryType {
        switch (raw ?? "").uppercased() {
        case "MONTHLY": return .monthly
        case "ANNUAL":  return .annual
        default: return .annual
        }
    }
}

struct WorkPolicyResponse: Decodable {
    let effectiveFrom: String?
    let workdays: [String]?
    let clockInTime: String?
    let clockOutTime: String?
    
    func toDomain() -> WorkPolicyEntity {
        .init(
            workdays: (workdays ?? []).compactMap(Self.mapWeekday),
            clockInTime: clockInTime,
            clockOutTime: clockOutTime
        )
    }
    
    nonisolated private static func mapWeekday(_ raw: String) -> Weekday? {
        switch raw.uppercased() {
        case "MON": return .mon
        case "TUE": return .tue
        case "WED": return .wed
        case "THU": return .thu
        case "FRI": return .fri
        case "SAT": return .sat
        case "SUN": return .sun
        default: return nil
        }
    }
}
