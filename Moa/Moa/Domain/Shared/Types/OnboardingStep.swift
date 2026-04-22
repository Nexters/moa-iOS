//
//  OnboardingStep.swift
//  Moa
//
//  Created by mirim on 2/18/26.
//

import Foundation

enum OnboardingStep: CaseIterable {
    case nickname
    case payroll
    case workPolicy
    case widget
    
    var orderIndex: Int {
        switch self {
        case .nickname: return 0
        case .payroll: return 1
        case .workPolicy: return 2
        case .widget: return 3
        }
    }
}
