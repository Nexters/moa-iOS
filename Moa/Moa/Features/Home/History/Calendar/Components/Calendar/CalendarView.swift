//
//  CalendarView.swift
//  Moa
//

import UIKit
import SnapKit

protocol CalendarViewDelegate: AnyObject {
    func calendarView(_ view: CalendarView, didSelectSchedule schedule: CalendarScheduleEntity)
    func calendarView(_ view: CalendarView, didChangeToDate date: Date)
    func calendarViewDidTapAdd(_ view: CalendarView)
}

final class CalendarView: UIView {

    // MARK: - Properties

    weak var delegate: CalendarViewDelegate?
    private let dataSource: CalendarDataSource

    private var selectedDate: Date? {
        didSet {
            guard !isSameDay(oldValue, selectedDate) else { return }
            reloadGrid()
        }
    }

    private var gridHeightConstraint: Constraint?
    private let cellHeight: CGFloat = 66
    private var isSliding           = false

    // MARK: - Subviews

    private let navBar     = CalendarNavigationBar(type: .history)
    private let infoCard   = CalendarInfoCard()
    private let weekHeader = CalendarWeekdayHeader()
    private let gridView   = CalendarGridView()

    // MARK: - Init

    init(dataSource: CalendarDataSource = CalendarDataSource()) {
        self.dataSource = dataSource
        super.init(frame: .zero)
        buildLayout()
        attachGestures()
        reloadAll()
    }

    required init?(coder: NSCoder) {
        self.dataSource = CalendarDataSource()
        super.init(coder: coder)
        buildLayout()
        attachGestures()
        reloadAll()
    }

    // MARK: - Layout

    private func buildLayout() {
        backgroundColor = AppColor.Background.primary
        [navBar, infoCard, weekHeader, gridView].forEach { addSubview($0) }

        navBar.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(32)
        }
        infoCard.snp.makeConstraints {
            $0.top.equalTo(navBar.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        weekHeader.snp.makeConstraints {
            $0.top.equalTo(infoCard.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview().inset(8)
            $0.height.equalTo(20)
        }
        gridView.snp.makeConstraints {
            $0.top.equalTo(weekHeader.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(8)
            gridHeightConstraint = $0.height.equalTo(cellHeight * 5).constraint
            $0.bottom.equalToSuperview()
        }

        navBar.delegate   = self
        gridView.delegate = self
    }

    private func attachGestures() {
        let left  = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        left.direction  = .left
        let right = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        right.direction = .right
        addGestureRecognizer(left)
        addGestureRecognizer(right)
    }

    // MARK: - Reload

    private func reloadAll() {
        navBar.setTitle(dataSource.monthTitle(for: dataSource.currentDate))
        navBar.setPrevButtonEnabled(dataSource.canMoveToPreviousMonth)
        reloadGrid()
    }

    func reloadGrid() {
        let days = dataSource.days(for: dataSource.currentDate, selectedDate: selectedDate)
        gridView.reload(with: days)
        guard !isSliding else { return }
        applyGridHeight()
    }

    private func applyGridHeight() {
        let rows = dataSource.rowCount(for: dataSource.currentDate)
        gridHeightConstraint?.update(offset: cellHeight * CGFloat(rows))
        layoutIfNeeded()
        superview?.layoutIfNeeded()
    }

    // MARK: - Swipe / Slide

    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            dataSource.moveToNextMonth()
            slide(.left)
        } else {
            // 가입 달 이전으로 스와이프 불가
            guard dataSource.canMoveToPreviousMonth else { return }
            dataSource.moveToPreviousMonth()
            slide(.right)
        }
    }

    private enum SlideDir { case left, right }

    private func slide(_ dir: SlideDir) {
        guard !isSliding else { return }
        isSliding = true

        let dx: CGFloat = dir == .left ? -bounds.width : bounds.width

        let snap = gridView.snapshotView(afterScreenUpdates: false)
        snap.map {
            gridView.superview?.addSubview($0) ?? addSubview($0)
            $0.frame = gridView.frame
        }

        reloadAll()
        applyGridHeight()

        gridView.transform = CGAffineTransform(translationX: -dx, y: 0)

        UIView.animate(withDuration: 0.28, delay: 0, options: .curveEaseInOut) {
            self.gridView.transform = .identity
            snap?.transform         = CGAffineTransform(translationX: dx, y: 0)
            snap?.alpha             = 0
        } completion: { _ in
            snap?.removeFromSuperview()
            self.isSliding = false
            self.delegate?.calendarView(self, didChangeToDate: self.dataSource.currentDate)
        }
    }

    // MARK: - Public Interface

    var currentMonth: Date { dataSource.currentDate }

    /// 가입일 적용 — HistoryViewController의 render(.loaded)에서 호출
    /// DataSource 내부에서 최초 1회만 실제 반영되므로 매 loaded마다 호출해도 안전
    func apply(joinedAt: Date) {
        dataSource.applyJoinedAt(joinedAt)
        // joinedAt 적용 후 현재 달의 prev 버튼 상태 즉시 갱신
        navBar.setPrevButtonEnabled(dataSource.canMoveToPreviousMonth)
    }

    /// API에서 받은 CalendarScheduleEntity 배열로 캘린더 갱신
    func updateCalendarSchedules(_ schedules: [CalendarScheduleEntity]) {
        dataSource.resetAndApply(schedules)
        reloadGrid()
    }

    func updateWorkInfo(_ info: EarningsEntity) {
        infoCard.update(with: info)
    }

    // MARK: - Helpers

    private func isSameDay(_ a: Date?, _ b: Date?) -> Bool {
        switch (a, b) {
        case (nil, nil):        return true
        case (let x?, let y?): return Calendar.current.isDate(x, inSameDayAs: y)
        default:               return false
        }
    }
}

// MARK: - CalendarNavigationBarDelegate

extension CalendarView: CalendarNavigationBarDelegate {

    func navigationBarDidTapPrev() {
        // 버튼이 disabled 상태여도 방어적으로 체크
        guard dataSource.canMoveToPreviousMonth else { return }
        dataSource.moveToPreviousMonth()
        slide(.right)
    }

    func navigationBarDidTapNext() {
        dataSource.moveToNextMonth()
        slide(.left)
    }

    func navigationBarDidTapAdd() {
        delegate?.calendarViewDidTapAdd(self)
    }
}

// MARK: - CalendarGridViewDelegate

extension CalendarView: CalendarGridViewDelegate {

    func gridView(_ grid: CalendarGridView, didTapSchedule schedule: CalendarScheduleEntity) {
        selectedDate = schedule.date

        var tapped        = dataSource.rawSchedule(for: schedule.date) ?? schedule
        tapped.isSelected = true

        delegate?.calendarView(self, didSelectSchedule: tapped)
    }
}
