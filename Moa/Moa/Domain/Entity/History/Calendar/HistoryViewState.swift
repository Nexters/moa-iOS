//
//  HistoryViewState.swift
//  Moa
//
//  Created by 정도현 on 3/17/26.
//

import Foundation

enum HistoryViewState: Equatable {
    case idle
    case loading
    case loaded(days: [CalendarDayEntity], earnings: EarningsEntity)
    /// 날짜 탭 후 상세 표시
    case dayDetail(date: Date, workday: WorkdayEntity, isPayday: Bool, salary: Int)
    case error(HistoryError)
}
