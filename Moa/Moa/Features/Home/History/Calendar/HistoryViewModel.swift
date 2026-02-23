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
        case refresh
        case changeMonth(Date)
        /// 날짜 탭 → 해당 날짜 상세 fetch
        case selectDay(Date)
        /// 상세 패널 닫기
        case deselectDay
    }
    
    // MARK: - Dependencies
    
    private let historyUseCase: HistoryUseCase
    
    // MARK: - Private State
    
    private var cancellables     = Set<AnyCancellable>()
    private var currentYear:  Int?
    private var currentMonth: Int?
    private var histories:    [History]       = []
    private var earningsInfo: EarningsEntity?
    
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
        case .viewDidLoad, .refresh:        loadCurrentMonth()
        case .changeMonth(let d): loadMonth(from: d)
        case .selectDay(let d):   fetchDayDetail(date: d)
        case .deselectDay:        publishCalendar()
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
        
        let cal   = Calendar.korea
        let year  = cal.component(.year,  from: date)
        let month = cal.component(.month, from: date)
        
        currentYear  = year
        currentMonth = month
        
        Task { @MainActor in
            do {
                async let historyTask  = historyUseCase.getWorkdayList(year: year, month: month)
                async let earningsTask = historyUseCase.getEarningsInfo(year: year, month: month)
                let (histories, earnings) = try await (historyTask, earningsTask)
                self.histories    = histories
                self.earningsInfo = earnings
                publishCalendar()
            } catch {
                state = .error(.network)
            }
        }
    }
}

// MARK: - Day Detail

private extension HistoryViewModel {
    
    func fetchDayDetail(date: Date) {
        let formatter        = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone   = TimeZone(identifier: "Asia/Seoul")
        let dateString       = formatter.string(from: date)
        
        Task { @MainActor in
            do {
                let workday = try await historyUseCase.fetchWorkday(date: dateString)
                state = .dayDetail(date: date, workday: workday)
            } catch {
                state = .error(.network)
            }
        }
    }
}

// MARK: - Publish

private extension HistoryViewModel {
    
    func publishCalendar() {
        guard let year     = currentYear,
              let month    = currentMonth,
              let earnings = earningsInfo
        else {
            state = .error(.dataCorrupted)
            return
        }
        let days = mapToCalendarDays(histories, year: year, month: month)
        state = .loaded(days: days, earnings: earnings)
    }
}

// MARK: - Mapping

private extension HistoryViewModel {
    /// UserDefaults에 저장된 월급날 (1~31, 없으면 nil)
    var payday: Int? {
        let day = UserDefaults.standard.integer(forKey: "payday")
        return day > 0 ? day : nil
    }
    
    func mapToCalendarDays(
        _ histories: [History],
        year: Int,
        month: Int
    ) -> [CalendarDay] {
        
        let formatter        = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone   = TimeZone(identifier: "Asia/Seoul")
        
        let calendar  = Calendar.korea
        let today     = Date()
        let paydayDay = payday  // 월급날 (옵셔널 Int)
        
        return histories.compactMap { history in
            guard let date = formatter.date(from: history.date) else { return nil }
            
            let isToday      = calendar.isDate(date, inSameDayAs: today)
            let dayOfMonth   = calendar.component(.day, from: date)
            let isPayday     = paydayDay == dayOfMonth
            
            // WorkdayType 기반 기본 타입 결정
            let workType: CalendarDayType
            switch history.type {
            case .work:
                let isPastOrToday = calendar.compare(date, to: today, toGranularity: .day) != .orderedDescending
                workType = isPastOrToday ? .worked : .scheduled
            case .vacation:
                workType = .singleLabel(.vacation)
            case .none:
                workType = .none
            }
            
            // payday 오버레이:
            //   payday + vacation → dualLabel (월급 · 휴가)
            //   payday + 그 외    → singleLabel(.payday)
            //   payday 아님       → workType 그대로
            let finalType: CalendarDayType
            if isPayday {
                if workType == .singleLabel(.vacation) {
                    finalType = .dualLabel         // 월급 · 휴가
                } else {
                    finalType = .singleLabel(.payday)  // 월급
                }
            } else {
                finalType = workType
            }
            
            return CalendarDay(
                date: date,
                contentType: finalType,
                isToday: isToday,
                isSelected: false,
                isCurrentMonth: true
            )
        }
    }
}


// MARK: - State / Error

enum HistoryViewState: Equatable {
    case idle
    case loading
    case loaded(days: [CalendarDay], earnings: EarningsEntity)
    /// 날짜 탭 후 상세 표시
    case dayDetail(date: Date, workday: WorkdayEntity)
    case error(HistoryError)
}

enum HistoryError: Equatable {
    case network
    case dataCorrupted
}
