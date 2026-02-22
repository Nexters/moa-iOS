//
//  HistoryViewController.swift
//  Moa
//
//  Created by 정도현 on 2/19/26.
//

import UIKit
import SnapKit
import Combine

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

struct CalendarDay: Equatable {
    let date: Date
    let contentType: CalendarDayType
    let isToday: Bool
    let isSelected: Bool
    let isCurrentMonth: Bool
}


final class HistoryViewController: BaseViewController {
    
    // MARK: - Properties
    
    private let viewModel: HistoryViewModel
    
    /// CalendarView에서 마지막으로 선택된 날짜
    private var selectedDate: Date?
    
    // MARK: - UI
    
    private let calendarView = CalendarView()
    
    // MARK: - Init
    
    init(viewModel: HistoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    weak var coordinatorDelegate: HistoryViewControllerCoordinatorDelegate?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bind()
        viewModel.send(.viewDidLoad)
    }
    
    override func setupUI() {
        replaceSystemBackButtonWithAppBackButton()
        
        view.backgroundColor = AppColor.Background.primary
        calendarView.delegate = self
        
        view.addSubview(calendarView)
        
        calendarView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    override func bind() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.render(state)
            }
            .store(in: &cancellables)
    }
}

// MARK: - Bind

private extension HistoryViewController {
    
    
    func render(_ state: HistoryViewState) {
        switch state {
            
        case .idle:
            break
            
        case .loading:
            showLoading()
            
        case .loaded(let days, let earnings):
            hideLoading()
            
            // calendarView.updateCalendarDays(days)
            
            calendarView.updateWorkInfo(
               earnings
            )
            
        case .error:
            hideLoading()
        }
    }
}

private extension HistoryViewController {
    
    func showLoading() {
        // 필요하면 ActivityIndicator 추가
    }
    
    func hideLoading() {
        // 필요하면 로딩 제거
    }
    
    func handleError(_ error: HistoryError) {
        let message: String
        
        switch error {
        case .network:
            message = "네트워크 오류가 발생했습니다."
        case .dataCorrupted:
            message = "데이터를 불러올 수 없습니다."
        }
    }
}


// MARK: - CalendarViewDelegate

extension HistoryViewController: CalendarViewDelegate {
    
    func calendarView(_ view: CalendarView, didSelectDay day: CalendarDay) {
        selectedDate = day.date
    }
    
    func calendarView(_ view: CalendarView, didChangeToDate date: Date) {
        selectedDate = nil
        viewModel.send(.changeMonth(date))
    }
    
    func calendarViewDidTapAdd(_ view: CalendarView) {
        // Coordinator 연결 시 여기서 처리
    }
}
