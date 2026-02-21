//
//  HistoryViewController.swift
//  Moa
//
//  Created by 정도현 on 2/19/26.
//

import UIKit
import SnapKit


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

final class HistoryViewController: BaseViewController {
    
    private let calendarView = CalendarView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func setupUI() {
        view.backgroundColor = AppColor.Background.primary
        
        replaceSystemBackButtonWithAppBackButton()
        
        calendarView.delegate = self
        
        view.addSubview(calendarView)
        
        calendarView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        calendarView.updateWorkInfo(
            CalendarWorkInfo(
                workedHours: "12",
                totalHours: "20",
                earnedSalary: "300,000",
                totalSalary: "1,500,000"
            )
        )
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
}

extension HistoryViewController: CalendarViewDelegate {
    
    func calendarView(_ view: CalendarView, didSelectDay day: CalendarDay) {
        // e.g. viewModel.handleDaySelection(day)
    }
    
    func calendarView(_ view: CalendarView, didChangeToDate date: Date) {
        // e.g. viewModel.fetchWorkInfo(for: date)
    }
    
    func calendarViewDidTapAdd(_ view: CalendarView) {
        // + 버튼 → 근무 추가 플로우
    }
}

@available(iOS 17.0, *)
#Preview {
    HistoryViewController()
}
