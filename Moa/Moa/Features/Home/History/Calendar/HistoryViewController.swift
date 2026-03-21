//
//  HistoryViewController.swift
//  Moa
//

import UIKit
import SnapKit
import Combine

// MARK: - Coordinator Delegate

protocol HistoryViewControllerCoordinatorDelegate: AnyObject {
    func historyViewControllerDidTapAdd(
        _ vc: HistoryViewController
    )
    func historyViewControllerDidTapEdit(
        _ vc: HistoryViewController,
        workday: WorkdayEntity,
        date: Date
    )
}

// MARK: - HistoryViewController

final class HistoryViewController: BaseViewController {

    // MARK: - Properties

    private let viewModel: HistoryViewModel
    private var selectedDate: Date?

    // MARK: - UI

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        return sv
    }()

    /// 스크롤 내부 컨테이너
    private let contentView = UIView()

    private let calendarView: CalendarView = {
        let view = CalendarView()
        view.layer.backgroundColor = AppColor.Background.primary.cgColor
        view.layer.cornerRadius  = 16
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        view.clipsToBounds       = true
        return view
    }()

    private let detailContainer: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()

    private lazy var detailView: WorkdayDetailView = {
        let view = WorkdayDetailView()
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

        setupUI()
        bind()
        viewModel.send(.viewDidLoad)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.send(.refresh)
    }

    // MARK: - Setup

    override func setupUI() {
        replaceSystemBackButtonWithAppBackButton()
        view.backgroundColor = AppColor.Background.primary

        calendarView.delegate = self

        // MARK: hierarchy

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubViews([
            calendarView,
            detailContainer
        ])

        // detailView inside container
        detailContainer.addSubview(detailView)
        detailView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(28)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(28)
        }

        // MARK: constraints

        // scrollView
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }

        // contentView (⭐️ 중요)
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(scrollView) // vertical scroll 핵심
        }

        // calendarView
        calendarView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }

        // detailContainer
        detailContainer.snp.makeConstraints {
            $0.top.equalTo(calendarView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
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
                isLoading
                ? LoadingManager.shared.show()
                : LoadingManager.shared.hide()
            }
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

            if let date = selectedDate {
                viewModel.send(.selectDay(date))
            } else {
                hideDetail()
            }

        case .dayDetail(let date, let workday, let isPayday, let salary):
            detailView.configure(
                date: date,
                workday: workday,
                isPayday: isPayday,
                salary: salary
            )
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
        detailContainer.alpha = 0

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
        guard presentedViewController == nil else { return }

        let msg: String
        switch error {
        case .network:       msg = "네트워크 오류가 발생했습니다."
        case .dataCorrupted: msg = "데이터를 불러올 수 없습니다."
        }

        let vc = MoaAlertViewController(message: msg)
        present(vc, animated: true)
    }
}

// MARK: - CalendarViewDelegate

extension HistoryViewController: CalendarViewDelegate {

    func calendarView(_ view: CalendarView, didSelectDay day: CalendarDayEntity) {
        selectedDate = day.date
        viewModel.send(.selectDay(day.date))
    }

    func calendarView(_ view: CalendarView, didChangeToDate date: Date) {
        selectedDate = nil
        viewModel.send(.deselectDay)
        viewModel.send(.changeMonth(date))
    }

    func calendarViewDidTapAdd(_ view: CalendarView) {
        coordinatorDelegate?.historyViewControllerDidTapAdd(self)
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

    func workdayDetailViewDidTapPaydayTicket(_ view: WorkdayDetailView) {
        presentPaydayBottomSheet()
    }
}

// MARK: - Payday BottomSheet

private extension HistoryViewController {

    func presentPaydayBottomSheet() {
        let currentPayday = UserDefaults.standard.integer(forKey: "payday")
        let sheet = PaydaySelectionBottomSheet(initialPayday: currentPayday)
        sheet.delegate = self
        presentBottomSheet(sheet)
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
