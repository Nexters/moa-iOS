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
    private(set) var clockInTime: TimeIndicatorEntity
    private(set) var clockOutTime: TimeIndicatorEntity
    let shouldPresentTermsSheet: Bool
    private(set) var terms: [TermsEntity] = []

    // MARK: - Init
    
    init(
        usecase: OnboardingUsecase,
        selectedWeekdays: Set<Weekday>,
        shouldPresentTermsSheet: Bool,
        clockInTime: TimeIndicatorEntity?,
        clockOutTime: TimeIndicatorEntity?
    ) {
        self.usecase = usecase
        let defaultWeekdays: Set<Weekday> = [.mon, .tue, .wed, .thu, .fri]
        self.selectedWeekdays = selectedWeekdays.isEmpty ? defaultWeekdays : selectedWeekdays
        self.shouldPresentTermsSheet = shouldPresentTermsSheet
        self.clockInTime = clockInTime ?? .init(hour: 9, minute: 0)
        self.clockOutTime = clockOutTime ?? .init(hour: 18, minute: 0)
    }

    // MARK: - Actions
    
    func markTermsSheetPresented() {
        hasPresentedTermsSheet = true
    }

    func updateSelectedWeekdays(_ weekdays: Set<Weekday>) {
        selectedWeekdays = weekdays
    }
    
    func updateWorkPolicy() async throws {
        guard selectedWeekdays.isEmpty == false else { throw DomainError.missingRequiredData }
        _ = try await usecase.updateWorkPolicy(selectedWeekdays: Array(selectedWeekdays), clockInTime: clockInTime, clockOutTime: clockOutTime)
        Analytics.track(.workPolicyNextClicked(isModified: false))
    }
    
    func workingHoursConfirmFromBottomSheet(
        start: TimeIndicatorEntity,
        end: TimeIndicatorEntity
    ) {
        clockInTime = start
        clockOutTime = end
    }
    
    func loadTerms() async throws {
        let fetched = try await usecase.getTerms()
        self.terms = fetched
    }
    
    func updateTermsAgreement(agreements: [String: Bool]) async throws {
        let entities = agreements.map { AgreementEntity(code: $0.key, agreed: $0.value) }
        
        _ = try await usecase.updateTermsAgreement(to: entities)
    }
}
