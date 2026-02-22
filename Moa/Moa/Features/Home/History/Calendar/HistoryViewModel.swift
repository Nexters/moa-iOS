//
//  HistoryViewModel.swift
//  Moa
//
//  Created by 정도현 on 2/22/26.
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
        case changeMonth(Date)
    }

    // MARK: - Dependencies

    private let historyUseCase: HistoryUseCase

    // MARK: - Private State

    private var cancellables = Set<AnyCancellable>()
    private var currentYear: Int?
    private var currentMonth: Int?
    private var histories: [History] = []

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

        case .viewDidLoad:
            loadCurrentMonth()

        case let .changeMonth(date):
            loadMonth(from: date)
        }
    }
}

// MARK: - Data Loading

private extension HistoryViewModel {

    func loadCurrentMonth() {
        let now = Date()
        loadMonth(from: now)
    }

    func loadMonth(from date: Date) {
        guard state != .loading else { return }

        state = .loading

        let calendar = Calendar.korea
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)

        currentYear = year
        currentMonth = month

        fetchHistory(year: year, month: month)
    }

    func fetchHistory(year: Int, month: Int) {
        Task { @MainActor in
            do {
                let result = try await historyUseCase
                    .getWorkdayList(year: year, month: month)

                apply(result)

            } catch {
                state = .error(.network)
            }
        }
    }

    func apply(_ histories: [History]) {
        self.histories = histories
        publish()
    }
}

// MARK: - Publish

private extension HistoryViewModel {

    func publish() {
        guard let year = currentYear,
              let month = currentMonth else {
            state = .error(.dataCorrupted)
            return
        }

        let days = mapToCalendarDays(
            histories,
            year: year,
            month: month
        )

        state = .loaded(days)
    }
}

// MARK: - Mapping

private extension HistoryViewModel {

    func mapToCalendarDays(
        _ histories: [History],
        year: Int,
        month: Int
    ) -> [CalendarDay] {

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")

        let calendar = Calendar.korea
        let today = Date()

        return histories.compactMap { history in

            guard let date = formatter.date(from: history.date)
            else { return nil }

            let isToday = calendar.isDate(date, inSameDayAs: today)

            let type: CalendarDayType

            switch history.type {
            case .work:
                type = .worked

            case .vacation:
                type = .singleLabel(.vacation)

            case .none:
                type = .none
            }

            return CalendarDay(
                date: date,
                contentType: type,
                isToday: isToday,
                isSelected: false,
                isCurrentMonth: true
            )
        }
    }
}

enum HistoryViewState: Equatable {
    case idle
    case loading
    case loaded([CalendarDay])
    case error(HistoryError)
}

enum HistoryError: Equatable {
    case network
    case dataCorrupted
}
