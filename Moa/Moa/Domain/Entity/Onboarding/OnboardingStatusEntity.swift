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

extension OnboardingStatusEntity {
    enum NextStep {
        case step(OnboardingStep)
        case completed
    }

    var nextOnboardingStep: NextStep {
        if profile == nil {
            return .step(.nickname)
        }
        if payroll == nil {
            return .step(.payroll)
        }
        if workPolicy == nil || !hasRequiredTermsAgreed {
            return .step(.workPolicy)
        }
        return .completed
    }
}
