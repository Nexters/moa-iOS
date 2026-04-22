//
//  HistoryViewController.swift
//  Moa
//

import UIKit
import SnapKit
import Combine

// MARK: - CoordinatorDelegate

protocol HistoryViewControllerCoordinatorDelegate: AnyObject {
    func historyViewControllerDidTapEdit(
        _ vc: HistoryViewController,
        schedule: CalendarScheduleEntity?,
        selectedDate: Date?,
        joinedAt: Date?
    )
}

// MARK: - HistoryViewController

final class HistoryViewController: BaseViewController {

    private let viewModel: HistoryViewModel
    private var selectedDate: Date?
    /// 가장 최근에 수신한 joinedAt — coordinatorDelegate 호출 시 전달
    private var currentJoinedAt: Date?

    // MARK: - UI

    private let topBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColor.Container.primary
        return view
    }()

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical         = true
        return sv
    }()

    private let contentView = UIView()

    private let calendarView: CalendarView = {
        let view = CalendarView()
        view.backgroundColor = AppColor.Container.primary
        view.clipsToBounds   = true
        return view
    }()

    private let detailContainer: UIView = {
        let view    = UIView()
        view.isHidden = true
        return view
    }()

    private lazy var detailView: WorkdayDetailView = {
        let view      = WorkdayDetailView()
        view.delegate = self
        return view
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
        
        selectedDate = Date()
        viewModel.send(.viewDidLoad)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBarAppearance(backgroundColor: AppColor.Container.primary)
        viewModel.send(.refresh)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        configureNavigationBarAppearance(backgroundColor: AppColor.Background.primary)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        calendarView.layer.cornerRadius  = 16
        calendarView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }

    // MARK: - Setup

    override func setupUI() {
        replaceSystemBackButtonWithAppBackButton()
        view.backgroundColor = AppColor.Background.primary
        calendarView.delegate = self

        view.addSubview(topBackgroundView)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubViews([calendarView, detailContainer])
        detailContainer.addSubview(detailView)

        topBackgroundView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(300)
        }
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(scrollView)
        }
        calendarView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        detailContainer.snp.makeConstraints {
            $0.top.equalTo(calendarView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        detailView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(28)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(28)
        }
    }

    // MARK: - Bind

    override func bind() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.render($0) }
            .store(in: &cancellables)

        viewModel.$state
            .map { if case .loading = $0 { return true } else { return false } }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { isLoading in
                isLoading ? LoadingManager.shared.show() : LoadingManager.shared.hide()
            }
            .store(in: &cancellables)
    }

    // MARK: - Render

    private func render(_ state: HistoryViewState) {
        switch state {
        case .idle:
            break

        case .loading:
            break

        case .loaded(let schedules, let earnings, let joinedAt):
            currentJoinedAt = joinedAt
            calendarView.apply(joinedAt: joinedAt)
            calendarView.updateCalendarSchedules(schedules)
            calendarView.updateWorkInfo(earnings)
           
            let targetDate = selectedDate ?? Date()
            selectedDate = targetDate
            
            calendarView.selectDate(targetDate)
            viewModel.send(.selectDay(targetDate))

        case .dayDetail(let schedule, let salary):
            detailView.configure(schedule: schedule, salary: salary)
            showDetail()

        case .error(let error):
            handleError(error)
        }
    }

    // MARK: - Detail Show / Hide

    private func showDetail() {
        guard detailContainer.isHidden else { return }
        detailContainer.isHidden = false
        detailContainer.alpha    = 0
        UIView.animate(withDuration: 0.25) { self.detailContainer.alpha = 1 }
    }

    // MARK: - Error

    private func handleError(_ error: HistoryError) {
        guard presentedViewController == nil else { return }
        let msg: String
        switch error {
        case .network:       msg = "네트워크 오류가 발생했습니다."
        case .dataCorrupted: msg = "데이터를 불러올 수 없습니다."
        }
        let vc = MoaAlertViewController(message: msg)
        present(vc, animated: true)
    }

    private func presentPaydayBottomSheet() {
        let currentPayday = UserDefaults.standard.integer(forKey: "payday")
        let sheet         = PaydaySelectionBottomSheet(initialPayday: currentPayday)
        sheet.delegate    = self
        presentBottomSheet(sheet)
    }
}

// MARK: - CalendarViewDelegate

extension HistoryViewController: CalendarViewDelegate {

    func calendarView(_ view: CalendarView, didSelectSchedule schedule: CalendarScheduleEntity) {
        selectedDate = schedule.date
        viewModel.send(.selectDay(schedule.date))
    }

    func calendarView(_ view: CalendarView, didChangeToDate date: Date) {
        selectedDate = nil
        viewModel.send(.deselectDay)
        viewModel.send(.changeMonth(date))
    }

    func calendarViewDidTapAdd(
        _ view: CalendarView,
        selectedDate: Date?,
        schedule: CalendarScheduleEntity?
    ) {
        coordinatorDelegate?.historyViewControllerDidTapEdit(
            self,
            schedule: schedule,
            selectedDate: selectedDate,
            joinedAt: currentJoinedAt
        )
    }
}

// MARK: - WorkdayDetailViewDelegate

extension HistoryViewController: WorkdayDetailViewDelegate {

    func workdayDetailView(_ view: WorkdayDetailView, didTapEdit schedule: CalendarScheduleEntity) {
        coordinatorDelegate?.historyViewControllerDidTapEdit(
            self,
            schedule: schedule,
            selectedDate: schedule.date,
            joinedAt: currentJoinedAt
        )
    }

    func workdayDetailViewDidTapPaydayTicket(_ view: WorkdayDetailView) {
        presentPaydayBottomSheet()
    }
}

// MARK: - PaydaySelectionBottomSheetDelegate

extension HistoryViewController: PaydaySelectionBottomSheetDelegate {

    func paydaySelectionBottomSheet(
        _ sheet: PaydaySelectionBottomSheet,
        didTapConfirmButton selectedPayday: Int
    ) {
        UserDefaults.standard.set(selectedPayday, forKey: "payday")
        viewModel.send(.refresh)
    }
}
