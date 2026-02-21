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
    var scheduleType: ScheduleTypeOptionType       = .workday
    var dateRange:    ScheduleDateRange? = nil     // nil = 미선택
    var startTime:    TimeIndicatorEntity = .from(hour: 9,  minute: 0)
    var endTime:      TimeIndicatorEntity = .from(hour: 18, minute: 0)

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

    func formatted(_ date: Date) -> String {
        Self.formatter.string(from: date)
    }

    /// 단일 날짜면 "2026.02.21", 범위면 "2026.02.21 ~ 2026.02.25"
    var displayString: String {
        if Calendar.current.isDate(start, inSameDayAs: end) {
            return formatted(start)
        }
        return "\(formatted(start)) ~ \(formatted(end))"
    }

    init(single date: Date) { self.start = date; self.end = date }
    init(start: Date, end: Date) { self.start = start; self.end = end }
}

// MARK: - FixScheduleViewModel

final class FixScheduleViewModel {

    // MARK: Output

    @Published private(set) var state = FixScheduleViewState()

    // MARK: Input

    enum Input {
        case selectDate(Date)
        case selectScheduleType(ScheduleTypeOptionType)
        case selectStartTime(TimeIndicatorEntity)
        case selectEndTime(TimeIndicatorEntity)
        case confirmTapped
    }

    // MARK: Properties

    /// 화면 타입 (.add / .fix)
    let viewType: ScheduleTypeOptionViewType
    private var cancellables = Set<AnyCancellable>()

    // MARK: Init

    /// - Parameters:
    ///   - viewType: 추가(.add) / 수정(.fix)
    ///   - preselectedDate: 캘린더에서 이미 선택된 날짜 (추가 플로우)
    ///   - existingSchedule: 수정 플로우에서 기존 데이터 주입
    init(
        viewType: ScheduleTypeOptionViewType,
        preselectedDate: Date? = nil,
        existingSchedule: FixScheduleViewState? = nil
    ) {
        self.viewType = viewType
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
            guard state.isConfirmEnabled else { return }
            submitSchedule()
        }
    }
}

// MARK: - API (private)

private extension FixScheduleViewModel {

    func submitSchedule() {
        // TODO: Repository 연동
        // POST /schedules  (add)
        // PUT  /schedules/{id} (fix)
        //
        // ScheduleRepository.shared
        //     .saveSchedule(
        //         type:      state.scheduleType,
        //         date:      state.dateRange?.start,
        //         clockIn:   state.startTime.displayString,
        //         clockOut:  state.endTime.displayString
        //     )
        //     .receive(on: DispatchQueue.main)
        //     .sink { completion in ... } receiveValue: { _ in }
        //     .store(in: &cancellables)
    }
}
