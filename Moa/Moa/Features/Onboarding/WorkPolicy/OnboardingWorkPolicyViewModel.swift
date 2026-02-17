//
//  OnboardingWorkPolicyViewModel.swift
//  Moa
//
//  Created by mirim on 2/5/26.
//

import Foundation

final class OnboardingWorkPolicyViewModel {
    // MARK: - State
    private(set) var selectedWeekdays: Set<Weekday> = [.mon, .tue, .wed, .thu, .fri]

    // MARK: - Actions
    func updateSelectedWeekdays(_ weekdays: Set<Weekday>) {
        selectedWeekdays = weekdays
    }
}
