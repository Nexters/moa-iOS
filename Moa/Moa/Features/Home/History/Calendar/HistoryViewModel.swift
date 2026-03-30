//
//  HistoryViewModel.swift
//  Moa
//

import Foundation
import Combine

// MARK: - HistoryViewModel

final class HistoryViewModel {

    // MARK: - Output

    @Published private(set) var state: HistoryViewState = .idle

    // MARK: - Input

    enum Input {
        case viewDidLoad
        case refresh
        case changeMonth(Date)
        case selectDay(Date)
        case deselectDay
    }

    // MARK: - Dependencies

    private let historyUseCase: HistoryUseCase

    // MARK: - Private State

    private var cancellables  = Set<AnyCancellable>()
    private var currentYear:  Int?
    private var currentMonth: Int?
    private var calendarEntity: CalendarEntity?

    // MARK: - Init

    init(historyUseCase: HistoryUseCase) {
        self.historyUseCase = historyUseCase
    }

    deinit { cancellables.removeAll() }
}

// MARK: - Public Interface

extension HistoryViewModel {

    func send(_ input: Input) {
        switch input {
        case .viewDidLoad, .refresh:     loadCurrentMonth()
        case .changeMonth(let date):     loadMonth(from: date)
        case .selectDay(let date):       selectDay(date)
        case .deselectDay:               publishCalendar()
        }
    }
}

// MARK: - Month Loading

private extension HistoryViewModel {

    func loadCurrentMonth() {
        loadMonth(from: Date())
    }

    func loadMonth(from date: Date) {
        guard state != .loading else { return }
        state = .loading

        let calendar = Calendar.korea
        let year     = calendar.component(.year,  from: date)
        let month    = calendar.component(.month, from: date)

        currentYear  = year
        currentMonth = month

        Task { @MainActor in
            do {
                // getCalendarData 단일 호출로 earnings + schedules 모두 수신
                let entity      = try await historyUseCase.getCalendarData(year: year, month: month)
                calendarEntity  = entity
                publishCalendar()
            } catch {
                state = .error(.network)
            }
        }
    }
}

// MARK: - Day Selection
//
// 날짜 탭 시 별도 API 호출 없이
// 이미 받아둔 CalendarEntity.schedules에서 해당 날짜를 찾아 상세 표시
// → API 호출 횟수 절감 + 응답 대기 없는 즉각 반응

private extension HistoryViewModel {

    func selectDay(_ date: Date) {
        guard let entity = calendarEntity else { return }

        let calendar = Calendar.korea

        guard let schedule = entity.schedules.first(where: {
            calendar.isDate($0.date, inSameDayAs: date)
        }) else {
            // 해당 날짜 데이터 없음 → 빈 상태로 표시
            publishCalendar()
            return
        }

        state = .dayDetail(
            schedule: schedule,
            salary:   entity.earnings.standardSalary
        )
    }
}

// MARK: - Publish

private extension HistoryViewModel {

    func publishCalendar() {
        guard let entity = calendarEntity else {
            state = .error(.dataCorrupted)
            return
        }
        state = .loaded(
            schedules: entity.schedules,
            earnings:  entity.earnings
        )
    }
}
