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
    func historyViewControllerDidTapAdd(
        _ vc: HistoryViewController,
        preselectedDate: Date?
    )
    func historyViewControllerDidTapEdit(
        _ vc: HistoryViewController,
        workday: WorkdayEntity,
        date: Date
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

// MARK: - HistoryViewController
//
final class HistoryViewController: BaseViewController {

    // MARK: - Properties

    private let viewModel: HistoryViewModel
    private var selectedDate: Date?

    // MARK: - UI

    private let calendarView: CalendarView = {
        let v = CalendarView()
        v.layer.backgroundColor = AppColor.Background.primary.cgColor
        v.layer.cornerRadius  = 16
        v.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        v.clipsToBounds       = true
        return v
    }()

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical         = false
        return sv
    }()

    private let detailContainer: UIView = {
        let v = UIView()
        v.isHidden = true
        return v
    }()

    private lazy var detailView: WorkdayDetailView = {
        let v = WorkdayDetailView()
        v.delegate = self
        return v
    }()

    // MARK: - Init

    init(viewModel: HistoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    weak var coordinatorDelegate: HistoryViewControllerCoordinatorDelegate?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
        viewModel.send(.viewDidLoad)
    }

    // MARK: - Setup

    override func setupUI() {
        replaceSystemBackButtonWithAppBackButton()
        view.backgroundColor  = AppColor.Background.primary
        calendarView.delegate = self

        // detailView → detailContainer (좌우/상하 패딩)
        detailContainer.addSubview(detailView)
        detailView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(28)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(28)
        }

        // scrollView 안에 detailContainer만 배치
        scrollView.addSubview(detailContainer)
        detailContainer.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(scrollView)
        }

        view.addSubViews([calendarView, scrollView])

        // calendarView
        calendarView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }

        // scrollView
        scrollView.snp.makeConstraints {
            $0.top.equalTo(calendarView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }

    override func bind() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.render($0) }
            .store(in: &cancellables)
    }
}

// MARK: - Render

private extension HistoryViewController {

    func render(_ state: HistoryViewState) {
        switch state {
        case .idle:
            break
        case .loading:
            break
        case .loaded(let days, let earnings):
            calendarView.updateCalendarDays(days)
            calendarView.updateWorkInfo(earnings)
            hideDetail()
        case .dayDetail(let date, let workday):
            detailView.configure(date: date, workday: workday)
            showDetail()
        case .error(let error):
            handleError(error)
        }
    }
}

// MARK: - Detail Show / Hide

private extension HistoryViewController {

    func showDetail() {
        guard detailContainer.isHidden else { return }
        detailContainer.isHidden = false
        detailContainer.alpha    = 0
        UIView.animate(withDuration: 0.25) {
            self.detailContainer.alpha = 1
        }
    }

    func hideDetail() {
        guard !detailContainer.isHidden else { return }
        UIView.animate(withDuration: 0.2) {
            self.detailContainer.alpha = 0
        } completion: { _ in
            self.detailContainer.isHidden = true
        }
    }
}

// MARK: - Error

private extension HistoryViewController {

    func handleError(_ error: HistoryError) {
        let msg: String
        switch error {
        case .network:       msg = "네트워크 오류가 발생했습니다."
        case .dataCorrupted: msg = "데이터를 불러올 수 없습니다."
        }
        let alert = UIAlertController(title: "오류", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - CalendarViewDelegate

extension HistoryViewController: CalendarViewDelegate {

    func calendarView(_ view: CalendarView, didSelectDay day: CalendarDay) {
        selectedDate = day.date
        viewModel.send(.selectDay(day.date))
    }

    func calendarView(_ view: CalendarView, didChangeToDate date: Date) {
        selectedDate = nil
        viewModel.send(.deselectDay)
        viewModel.send(.changeMonth(date))
    }

    func calendarViewDidTapAdd(_ view: CalendarView) {
        // + 버튼 → 날짜 전달 없이 일정 추가
        coordinatorDelegate?.historyViewControllerDidTapAdd(self, preselectedDate: nil)
    }
}

// MARK: - WorkdayDetailViewDelegate

extension HistoryViewController: WorkdayDetailViewDelegate {

    func workdayDetailView(
        _ view: WorkdayDetailView,
        didTapEdit workday: WorkdayEntity,
        date: Date
    ) {
        coordinatorDelegate?.historyViewControllerDidTapEdit(self, workday: workday, date: date)
    }
}
