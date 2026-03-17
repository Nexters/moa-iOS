//
//  CalendarView.swift
//  Moa
//
//  Created by 정도현 on 2/19/26.
//

import UIKit
import SnapKit

protocol CalendarViewDelegate: AnyObject {
    func calendarView(_ view: CalendarView, didSelectDay day: CalendarDayEntity)
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

    /// gridView 높이 제약 — 월별 실제 행 수에 맞게 업데이트
    private var gridHeightConstraint: Constraint?
    private let cellHeight: CGFloat = 66

    /// 슬라이드 애니메이션 진행 중 여부 — 이 중에는 높이 레이아웃 갱신 스킵
    private var isSliding = false
    
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
        reloadGrid()
    }
    
    func reloadGrid() {
        let days = dataSource.days(for: dataSource.currentDate, selectedDate: selectedDate)
        gridView.reload(with: days)

        // 슬라이드 중에는 높이 레이아웃 갱신을 스킵
        // (슬라이드 완료 후 slide() 내부에서 적용됨)
        guard !isSliding else { return }
        applyGridHeight()
    }

    /// dataSource.rowCount 기반으로 gridView 높이를 즉시 반영
    private func applyGridHeight() {
        let rows = dataSource.rowCount(for: dataSource.currentDate)
        gridHeightConstraint?.update(offset: cellHeight * CGFloat(rows))
        // 외부(superview)로 레이아웃 전파 — 애니메이션 없이 즉시
        layoutIfNeeded()
        superview?.layoutIfNeeded()
    }
    
    // MARK: - Swipe / Slide
    
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            dataSource.moveToNextMonth()
            slide(.left)
        } else {
            dataSource.moveToPreviousMonth()
            slide(.right)
        }
    }
    
    private enum SlideDir { case left, right }
    
    private func slide(_ dir: SlideDir) {
        guard !isSliding else { return }
        isSliding = true

        let dx: CGFloat = dir == .left ? -bounds.width : bounds.width
        
        // 현재 grid 스냅샷 (슬라이드 아웃용)
        let snap = gridView.snapshotView(afterScreenUpdates: false)
        snap.map {
            addSubview($0)
            $0.frame = gridView.frame
        }
        
        // 새 달 데이터 로드 + 높이 즉시 반영 (애니메이션 전에 적용)
        reloadAll()
        applyGridHeight()

        // 새 grid: 반대편에서 슬라이드 인
        gridView.transform = CGAffineTransform(translationX: -dx, y: 0)
        
        UIView.animate(withDuration: 0.28, delay: 0, options: .curveEaseInOut) {
            self.gridView.transform = .identity
            snap?.transform = CGAffineTransform(translationX: dx, y: 0)
            snap?.alpha = 0
        } completion: { _ in
            snap?.removeFromSuperview()
            self.isSliding = false
            self.delegate?.calendarView(self, didChangeToDate: self.dataSource.currentDate)
        }
    }
    
    // MARK: - Public Interface
    
    var currentMonth: Date { dataSource.currentDate }
    
    func setRawDayType(_ type: CalendarDayType, for date: Date) {
        dataSource.setRawDayType(type, for: date)
        reloadGrid()
    }
    
    /// API 데이터 업데이트 — 슬라이드 중이 아닐 때만 높이 갱신
    func updateCalendarDays(_ days: [CalendarDayEntity]) {
        dataSource.resetAndApply(days)
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
    
    func gridView(_ grid: CalendarGridView, didTapDay day: CalendarDayEntity) {
        selectedDate = day.date
        
        let contentType = dataSource.rawType(for: day.date)
        let isToday     = Calendar.current.isDateInToday(day.date)
        
        let rawDay = CalendarDayEntity(
            date: day.date,
            contentType: contentType,
            isToday: isToday,
            isSelected: selectedDate != nil &&
                Calendar.current.isDate(selectedDate!, inSameDayAs: day.date),
            isCurrentMonth: day.isCurrentMonth
        )
        
        delegate?.calendarView(self, didSelectDay: rawDay)
    }
}
