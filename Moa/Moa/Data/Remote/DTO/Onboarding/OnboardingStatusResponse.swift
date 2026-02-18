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
