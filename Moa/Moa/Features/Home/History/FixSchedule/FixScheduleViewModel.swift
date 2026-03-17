//
//  FixScheduleViewModel.swift
//  Moa
//
//  Created by 정도현 on 2/21/26.
//

import Foundation
import Combine


final class FixScheduleViewModel {

    // MARK: - Output

    @Published private(set) var state       = FixScheduleViewState()
    @Published private(set) var submitState = FixScheduleSubmitState.idle

    // MARK: - Input

    enum Input {
        case selectDate(Date)
        case selectScheduleType(ScheduleTypeOptionType)
        case selectStartTime(TimeIndicatorEntity)
        case selectEndTime(TimeIndicatorEntity)
        case confirmTapped
    }

    // MARK: - Properties

    let viewType: ScheduleTypeOptionViewType
    private let historyUseCase: HistoryUseCase
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    init(
        viewType: ScheduleTypeOptionViewType,
        historyUseCase: HistoryUseCase,
        preselectedDate: Date? = nil,
        existingSchedule: FixScheduleViewState? = nil
    ) {
        self.viewType       = viewType
        self.historyUseCase = historyUseCase

        if let existing = existingSchedule {
            state = existing
        } else if let date = preselectedDate {
            state.dateRange = ScheduleDateRangeEntity(single: date)
        }
    }

    deinit { cancellables.removeAll() }
}

// MARK: - Public Interface

extension FixScheduleViewModel {

    func send(_ input: Input) {
        switch input {
        case .selectDate(let date):
            state.dateRange = ScheduleDateRangeEntity(single: date)

        case .selectScheduleType(let type):
            state.scheduleType = type

        case .selectStartTime(let t):
            state.startTime = t

        case .selectEndTime(let t):
            state.endTime = t

        case .confirmTapped:
            guard state.isConfirmEnabled,
                  submitState != .submitting
            else { return }
            submitSchedule()
        }
    }
}

// MARK: - Submit

private extension FixScheduleViewModel {

    func submitSchedule() {
        guard let dateRange = state.dateRange else { return }

        submitState = .submitting

        let dateString  = dateRange.startDateString
        let workdayType = workdayType(from: state.scheduleType)
        let startTime   = state.startTime
        let endTime     = state.endTime

        Task { @MainActor in
            do {
                try await historyUseCase.updateWorkday(
                    date: dateString,
                    type: workdayType,
                    clockInTime: workdayType == .vacation ? nil : startTime,
                    clockOutTime: workdayType == .vacation ? nil : endTime
                )
                submitState = .success

            } catch {
                let message = (error as? LocalizedError)?.errorDescription
                    ?? "일정을 저장하지 못했습니다. 다시 시도해주세요."
                submitState = .failure(message)
            }
        }
    }

    /// ScheduleTypeOptionType → WorkdayType 변환
    func workdayType(from type: ScheduleTypeOptionType) -> WorkdayType {
        switch type {
        case .vacation: return .vacation
        case .workday:  return .work
        }
    }
}

// MARK: - WorkdayEntity → FixScheduleViewState 변환 헬퍼

extension FixScheduleViewModel {

    static func makeState(from workday: WorkdayEntity, date: Date) -> FixScheduleViewState {
        var state = FixScheduleViewState()

        state.dateRange = ScheduleDateRangeEntity(single: date)

        switch workday.type {
        case .vacation: state.scheduleType = .vacation
        case .work, .none: state.scheduleType = .workday
        }

        if let clockIn  = workday.clockInTime  { state.startTime = clockIn  }
        if let clockOut = workday.clockOutTime { state.endTime   = clockOut }

        return state
    }
}
