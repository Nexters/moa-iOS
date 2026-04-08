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
                let entity     = try await historyUseCase.getCalendarData(year: year, month: month)
                calendarEntity = entity
                publishCalendar()
            } catch {
                state = .error(.network)
            }
        }
    }
}

// MARK: - Day Selection

private extension HistoryViewModel {

    func selectDay(_ date: Date) {
        guard let entity = calendarEntity else { return }

        let calendar = Calendar.korea

        guard let schedule = entity.schedules.first(where: {
            calendar.isDate($0.date, inSameDayAs: date)
        }) else {
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
            earnings:  entity.earnings,
            joinedAt:  entity.joinedAt   // CalendarEntity.joinedAt → View로 전달
        )
    }
}
