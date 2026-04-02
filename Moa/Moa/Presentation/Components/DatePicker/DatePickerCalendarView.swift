//
//  DatePickerCalendarView.swift
//  Moa
//
//  Created by 정도현 on 2/20/26.
//

import UIKit
import SnapKit

protocol DatePickerCalendarViewDelegate: AnyObject {
    func datePickerCalendarView(_ view: DatePickerCalendarView, didSelectDate date: Date)
}

/// 바텀시트에 임베드하는 날짜 선택 전용 캘린더
final class DatePickerCalendarView: UIView {

    // MARK: - Public

    weak var delegate: DatePickerCalendarViewDelegate?

    /// 현재 선택된 날짜
    private(set) var selectedDate: Date? = Calendar.current.startOfDay(for: Date())

    /// 현재 표시 중인 월
    var currentMonth: Date { dataSource.currentDate }

    // MARK: - Private

    private let dataSource: CalendarDataSource

    // MARK: - Subviews

    private let navBar     = CalendarNavigationBar(type: .bottomSheet)
    private let weekHeader = CalendarWeekdayHeader()
    private let gridView   = CalendarGridView(calendarType: .bottomSheet)

    // MARK: - Init

    init(dataSource: CalendarDataSource = CalendarDataSource()) {
        self.dataSource = dataSource
        super.init(frame: .zero)
        buildLayout()
        attachSwipeGestures()
        reloadAll()
    }

    required init?(coder: NSCoder) {
        self.dataSource = CalendarDataSource()
        super.init(coder: coder)
        buildLayout()
        attachSwipeGestures()
        reloadAll()
    }

    // MARK: - Layout

    private func buildLayout() {
        backgroundColor = AppColor.Container.primary

        [navBar, weekHeader, gridView].forEach { addSubview($0) }

        navBar.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(28)
        }
        weekHeader.snp.makeConstraints {
            $0.top.equalTo(navBar.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(8)
            $0.height.equalTo(20)
        }
        gridView.snp.makeConstraints {
            $0.top.equalTo(weekHeader.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(8)
            $0.bottom.equalToSuperview()
        }

        navBar.delegate   = self
        gridView.delegate = self
    }

    private func attachSwipeGestures() {
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

    private func reloadGrid() {
        let days = dataSource.days(for: dataSource.currentDate, selectedDate: selectedDate)
        gridView.reload(with: days)
    }

    // MARK: - Swipe

    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            dataSource.moveToNextMonth()
            slide(.left)
        } else {
            guard dataSource.canMoveToPreviousMonth else { return }
            dataSource.moveToPreviousMonth()
            slide(.right)
        }
    }

    private enum SlideDir { case left, right }

    private func slide(_ dir: SlideDir) {
        let dx: CGFloat = dir == .left ? -bounds.width : bounds.width

        let snap = gridView.snapshotView(afterScreenUpdates: false)
        snap.map {
            addSubview($0)
            $0.frame = gridView.frame
        }

        reloadAll()
        gridView.transform = CGAffineTransform(translationX: -dx, y: 0)

        UIView.animate(withDuration: 0.28, delay: 0, options: .curveEaseInOut) {
            self.gridView.transform = .identity
            snap?.transform = CGAffineTransform(translationX: dx, y: 0)
            snap?.alpha = 0
        } completion: { _ in
            snap?.removeFromSuperview()
        }
    }

    // MARK: - Public Interface

    func setSelectedDate(_ date: Date?) {
        selectedDate = date
        reloadGrid()
    }

    /// 가입일 적용 — DatePickerCalendarBottomSheet 초기화 시 호출
    /// DataSource 내부에서 최초 1회만 실제 반영되므로 중복 호출해도 안전
    func apply(joinedAt: Date) {
        dataSource.applyJoinedAt(joinedAt)
        navBar.setPrevButtonEnabled(dataSource.canMoveToPreviousMonth)
    }
}

// MARK: - CalendarNavigationBarDelegate

extension DatePickerCalendarView: CalendarNavigationBarDelegate {

    func navigationBarDidTapPrev() {
        guard dataSource.canMoveToPreviousMonth else { return }
        dataSource.moveToPreviousMonth()
        slide(.right)
    }

    func navigationBarDidTapNext() {
        dataSource.moveToNextMonth()
        slide(.left)
    }

    func navigationBarDidTapAdd() {
        // 날짜 선택 캘린더에서는 사용하지 않음
    }
}

// MARK: - CalendarGridViewDelegate

extension DatePickerCalendarView: CalendarGridViewDelegate {

    func gridView(_ grid: CalendarGridView, didTapSchedule schedule: CalendarScheduleEntity) {
        selectedDate = schedule.date
        reloadGrid()
        delegate?.datePickerCalendarView(self, didSelectDate: schedule.date)
    }
}
