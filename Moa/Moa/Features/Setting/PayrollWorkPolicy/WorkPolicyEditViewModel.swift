//
//  WorkPolicyEditViewModel.swift
//  Moa
//
//  Created by mirim on 2/22/26.
//

import Foundation

final class WorkPolicyEditViewModel {
    
    // MARK: - Dependencies
    
    private let settingUsecase: SettingUsecase
    
    // MARK: - State
    
    private(set) var selectedWeekdays: Set<Weekday>
    private(set) var hasPresentedTermsSheet: Bool = false
    private(set) var clockInTime: TimeIndicatorEntity
    private(set) var clockOutTime: TimeIndicatorEntity

    // MARK: - Init
    
    init(
        usecase: SettingUsecase,
        selectedWeekdays: Set<Weekday>,
        clockInTime: TimeIndicatorEntity?,
        clockOutTime: TimeIndicatorEntity?
    ) {
        self.settingUsecase = usecase
        let defaultWeekdays: Set<Weekday> = [.mon, .tue, .wed, .thu, .fri]
        self.selectedWeekdays = selectedWeekdays.isEmpty ? defaultWeekdays : selectedWeekdays
        self.clockInTime = clockInTime ?? .init(hour: 9, minute: 0)
        self.clockOutTime = clockOutTime ?? .init(hour: 18, minute: 0)
    }

    // MARK: - Actions

    func updateSelectedWeekdays(_ weekdays: Set<Weekday>) {
        selectedWeekdays = weekdays
    }
    
    func updateWorkPolicy() async throws {
        guard selectedWeekdays.isEmpty == false else { throw DomainError.missingRequiredData }
        
        _ = try await settingUsecase.updateWorkPolicy(
            weekdays: Array(selectedWeekdays),
            clockInTime: clockInTime,
            clockOutTime: clockOutTime
        )
    }
    
    func workingHoursConfirmFromBottomSheet(
        start: TimeIndicatorEntity,
        end: TimeIndicatorEntity
    ) {
        clockInTime = start
        clockOutTime = end
    }
}
