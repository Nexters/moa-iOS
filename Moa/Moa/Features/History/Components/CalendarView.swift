//
//  CalendarView.swift
//  Moa
//
//  Created by 정도현 on 2/19/26.
//

import UIKit
import SnapKit

protocol CalendarViewDelegate: AnyObject {
    func calendarView(_ view: CalendarView, didSelectDay day: CalendarDay)
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
    
    // MARK: - Subviews
    
    private let navBar     = CalendarNavigationBar()
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
            $0.height.equalTo(88)
        }
        weekHeader.snp.makeConstraints {
            $0.top.equalTo(infoCard.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview().inset(8)
            $0.height.equalTo(20)
        }
        gridView.snp.makeConstraints {
            $0.top.equalTo(weekHeader.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(8)
            $0.height.equalTo(66 * 6)
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
    
    /// 헤더 타이틀 + 그리드 모두 갱신
    private func reloadAll() {
        navBar.setTitle(dataSource.monthTitle(for: dataSource.currentDate))
        navBar.setNextEnabled(dataSource.canMoveToNextMonth())
        reloadGrid()
    }
    
    /// 그리드만 갱신 (selectedDate 변경 시 사용)
    private func reloadGrid() {
        let days = dataSource.days(for: dataSource.currentDate, selectedDate: selectedDate)
        gridView.reload(with: days)
    }
    
    // MARK: - Swipe / Slide
    
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            guard dataSource.canMoveToNextMonth() else { return }
            dataSource.moveToNextMonth()
            slide(.left)
            
        } else {
            dataSource.moveToPreviousMonth()
            slide(.right)
        }
    }
    
    private enum SlideDir { case left, right }
    
    private func slide(_ dir: SlideDir) {
        let dx: CGFloat = dir == .left ? -bounds.width : bounds.width
        
        // 현재 그리드 스냅샷
        let snap = gridView.snapshotView(afterScreenUpdates: false)
        snap.map {
            addSubview($0)
            $0.frame = gridView.frame
        }
        
        // 데이터 업데이트 후 그리드를 화면 밖에서 슬라이드인
        reloadAll()
        gridView.transform = CGAffineTransform(translationX: -dx, y: 0)
        
        UIView.animate(withDuration: 0.28, delay: 0, options: .curveEaseInOut) {
            self.gridView.transform = .identity
            snap?.transform = CGAffineTransform(translationX: dx, y: 0)
            snap?.alpha = 0
        } completion: { _ in
            snap?.removeFromSuperview()
            self.delegate?.calendarView(self, didChangeToDate: self.dataSource.currentDate)
        }
    }
    
    // MARK: - Public Interface
    
    var currentMonth: Date { dataSource.currentDate }
    
    func setRawDayType(_ type: CalendarDayType, for date: Date) {
        dataSource.setRawDayType(type, for: date)
        reloadGrid()
    }
    
    func updateWorkInfo(_ info: CalendarWorkInfo) {
        infoCard.update(with: info)
    }
    
    // MARK: - Helpers
    
    private func isSameDay(_ a: Date?, _ b: Date?) -> Bool {
        switch (a, b) {
        case (nil, nil):            return true
        case (let x?, let y?):     return Calendar.current.isDate(x, inSameDayAs: y)
        default:                    return false
        }
    }
}

// MARK: CalendarNavigationBarDelegate

extension CalendarView: CalendarNavigationBarDelegate {
    func navigationBarDidTapPrev() {
        dataSource.moveToPreviousMonth()
        slide(.right)
    }
    
    func navigationBarDidTapNext() {
        dataSource.moveToNextMonth()
        slide(.left)
    }
    
    func navigationBarDidTapAdd()  {
        delegate?.calendarViewDidTapAdd(self)
    }
}

// MARK: CalendarGridViewDelegate

extension CalendarView: CalendarGridViewDelegate {
    
    func gridView(_ grid: CalendarGridView, didTapDay day: CalendarDay) {
        
        selectedDate = day.date
        
        let contentType = dataSource.rawType(for: day.date)
        let isToday = Calendar.current.isDateInToday(day.date)
        
        let rawDay = CalendarDay(
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
