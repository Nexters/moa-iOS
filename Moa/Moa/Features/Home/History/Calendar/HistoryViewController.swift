//
//  HistoryViewController.swift
//  Moa
//
//  Created by 정도현 on 2/19/26.
//

import UIKit
import SnapKit

// MARK: - Coordinator Delegate

protocol HistoryViewControllerCoordinatorDelegate: AnyObject {
    /// + 버튼 탭
    func historyViewControllerDidTapAdd(
        _ vc: HistoryViewController
    )
}

// MARK: - CalendarLabelStyle / CalendarDayType / CalendarDay

enum CalendarLabelStyle: Equatable { case payday, vacation }

enum CalendarDayType: Equatable {
    case none
    case scheduled
    case worked
    case dualLabel
    case singleLabel(CalendarLabelStyle)
}

struct CalendarDay {
    let date: Date
    let contentType: CalendarDayType
    let isToday: Bool
    let isSelected: Bool
    let isCurrentMonth: Bool
}

// MARK: - HistoryViewController

final class HistoryViewController: BaseViewController {

    override var preferredStatusBarStyle:    UIStatusBarStyle { .lightContent }

    // MARK: - Delegate

    weak var coordinatorDelegate: HistoryViewControllerCoordinatorDelegate?

    // MARK: - State

    /// CalendarView에서 마지막으로 선택된 날짜
    private var selectedDate: Date?

    // MARK: - UI

    private let calendarView = CalendarView()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCalendar()
    }

    // MARK: - Setup

    private func setupCalendar() {
        replaceSystemBackButtonWithAppBackButton()
        
        view.backgroundColor = AppColor.Background.primary
        calendarView.delegate = self

        view.addSubview(calendarView)
        calendarView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        calendarView.updateWorkInfo(
            CalendarWorkInfo(
                workedHours:  "12",
                totalHours:   "20",
                earnedSalary: "300,000",
                totalSalary:  "1,500,000"
            )
        )
    }
}

// MARK: - CalendarViewDelegate

extension HistoryViewController: CalendarViewDelegate {

    func calendarView(_ view: CalendarView, didSelectDay day: CalendarDay) {
        // 날짜 셀 탭 → selectedDate 갱신
        selectedDate = day.date
    }

    func calendarView(_ view: CalendarView, didChangeToDate date: Date) {
        // 월 변경 시 선택 초기화
        selectedDate = nil
    }

    func calendarViewDidTapAdd(_ view: CalendarView) {
        // 선택된 날짜를 Coordinator에 전달
        coordinatorDelegate?.historyViewControllerDidTapAdd(self)
    }
}

// MARK: - Preview

@available(iOS 17.0, *)
#Preview {
    HistoryViewController()
}
