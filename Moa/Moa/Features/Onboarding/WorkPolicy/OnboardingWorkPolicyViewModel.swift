//
//  OnboardingWorkPolicyViewModel.swift
//  Moa
//
//  Created by mirim on 2/5/26.
//

import Foundation

final class OnboardingWorkPolicyViewModel {
    
    // MARK: - Dependencies
    
    private let usecase: OnboardingUsecase
    
    // MARK: - State
    
    private(set) var selectedWeekdays: Set<Weekday>
    private(set) var hasPresentedTermsSheet: Bool = false
    private(set) var clockInTime: String?
    private(set) var clockOutTime: String?
    let shouldPresentTermsSheet: Bool

    // MARK: - Init
    
    init(
        usecase: OnboardingUsecase,
        selectedWeekdays: Set<Weekday>,
        shouldPresentTermsSheet: Bool,
        clockInTime: String? = nil,
        clockOutTime: String? = nil
    ) {
        self.usecase = usecase
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
    
    func updateWorkPolicy() async throws {
        guard
            selectedWeekdays.isEmpty == false,
            let clockInTime,
            let clockOutTime
        else { return }
        
        _ = try await usecase.updateWorkPolicy(selectedWeekdays: Array(selectedWeekdays), clockInTime: clockInTime, clockOutTime: clockOutTime)
    }
}
