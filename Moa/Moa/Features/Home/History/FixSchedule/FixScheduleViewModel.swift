//
//  FixScheduleViewModel.swift
//  Moa
//
//  Created by 정도현 on 2/21/26.
//

import Foundation
import Combine

// MARK: - FixScheduleViewState

struct FixScheduleViewState: Equatable {
    var scheduleType: ScheduleTypeOptionType = .workday
    var dateRange:    ScheduleDateRange?     = nil
    var startTime:    TimeIndicatorEntity    = .from(hour: 9,  minute: 0)
    var endTime:      TimeIndicatorEntity    = .from(hour: 18, minute: 0)

    var isConfirmEnabled: Bool { dateRange != nil }
}

// MARK: - ScheduleDateRange

struct ScheduleDateRange: Equatable {
    let start: Date
    let end:   Date

    private static let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy.MM.dd"
        return f
    }()

    private static let serverFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.timeZone   = TimeZone(identifier: "Asia/Seoul")
        return f
    }()

    func formatted(_ date: Date) -> String { Self.formatter.string(from: date) }

    var displayString: String {
        if Calendar.current.isDate(start, inSameDayAs: end) {
            return formatted(start)
        }
        return "\(formatted(start)) ~ \(formatted(end))"
    }

    /// API 전송용 "yyyy-MM-dd" 문자열
    var startDateString: String { Self.serverFormatter.string(from: start) }

    init(single date: Date)      { self.start = date; self.end = date }
    init(start: Date, end: Date) { self.start = start; self.end = end }
}

// MARK: - SubmitState

enum FixScheduleSubmitState: Equatable {
    case idle
    case submitting
    case success
    case failure(String)
}

// MARK: - FixScheduleViewModel

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
            state.dateRange = ScheduleDateRange(single: date)
        }
    }

    deinit { cancellables.removeAll() }
}

// MARK: - Public Interface

extension FixScheduleViewModel {

    func send(_ input: Input) {
        switch input {
        case .selectDate(let date):
            state.dateRange = ScheduleDateRange(single: date)

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

        state.dateRange = ScheduleDateRange(single: date)

        switch workday.type {
        case .vacation: state.scheduleType = .vacation
        case .work, .none: state.scheduleType = .workday
        }

        if let clockIn  = workday.clockInTime  { state.startTime = clockIn  }
        if let clockOut = workday.clockOutTime { state.endTime   = clockOut }

        return state
    }
}
