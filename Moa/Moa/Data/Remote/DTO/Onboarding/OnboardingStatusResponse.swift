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

struct WorkPolicyResponse: Decodable {
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
