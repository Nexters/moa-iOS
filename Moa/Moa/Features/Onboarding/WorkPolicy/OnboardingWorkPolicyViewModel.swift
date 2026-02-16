//
//  OnboardingWorkPolicyViewModel.swift
//  Moa
//
//  Created by mirim on 2/5/26.
//

import Foundation

final class OnboardingWorkPolicyViewModel {
    // MARK: - State
    private(set) var selectedWeekdays: Set<Weekday>
    private(set) var hasPresentedTermsSheet: Bool = false
    private(set) var clockInTime: String?
    private(set) var clockOutTime: String?
    let shouldPresentTermsSheet: Bool

    // MARK: - Init
    init(
        selectedWeekdays: Set<Weekday>,
        shouldPresentTermsSheet: Bool,
        clockInTime: String? = nil,
        clockOutTime: String? = nil
    ) {
        let defaultWeekdays: Set<Weekday> = [.mon, .tue, .wed, .thu, .fri]
        self.selectedWeekdays = selectedWeekdays.isEmpty ? defaultWeekdays : selectedWeekdays
        self.shouldPresentTermsSheet = shouldPresentTermsSheet
        self.clockInTime = clockInTime
        self.clockOutTime = clockOutTime
    }

    // MARK: - Actions
    func markTermsSheetPresented() {
        hasPresentedTermsSheet = true
    }

    func updateSelectedWeekdays(_ weekdays: Set<Weekday>) {
        selectedWeekdays = weekdays
    }
}
