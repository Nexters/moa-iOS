//
//  WorkMainSummaryView.swift
//  Moa
//

import UIKit
import SnapKit

final class WorkMainSummaryView: UIView {
    
    // MARK: - Action
    
    var onTapTimeRow: (() -> Void)?
    
    // MARK: - UI
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor    = AppColor.Container.primary
        view.layer.cornerRadius = 16
        view.clipsToBounds      = true
        return view
    }()
    
    private lazy var wageRowView: KeyValueRowView = KeyValueRowView(type: .wageRow(wage: 0))
    
    /// 근무완료1 전용 누적 월급 행 — 배경에 blur 삽입
    private lazy var accumulatedWageRowView: KeyValueRowView = KeyValueRowView(type: .accumulatedWageRow(wage: 0))
    
    private let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColor.Divider.secondary
        return view
    }()
    
    /// idle / working: 탭 가능, chevron O
    private lazy var timeRowView: KeyValueRowView = {
        let row = KeyValueRowView(type: .timeRow(startTime: "", endTime: ""), showsChevron: true)
        row.onTap = { [weak self] in self?.onTapTimeRow?() }
        return row
    }()
    
    /// 근무완료1 / 최종완료: chevron O or X, tappable 여부 동적 결정
    private lazy var finishedTimeRowView: KeyValueRowView = {
        KeyValueRowView(type: .timeRow(startTime: "", endTime: ""), showsChevron: true)
    }()
    
    /// 휴가
    private lazy var vacationTimeRowView: KeyValueRowView = {
        let row = KeyValueRowView(
            type: .customRow(key: "근무 시간", value: "연차"),
            showsChevron: true
        )
        
        row.onTap = { [weak self] in self?.onTapTimeRow?() }
        return row
    }()
    
    private lazy var holidayRowView: KeyValueRowView = {
        let row = KeyValueRowView(
            type: .customRow(key: "근무 시간", value: "근무 없음"),
            showsChevron: true
        )
        
        row.onTap = { [weak self] in self?.onTapTimeRow?() }
        return row
    }()
    
    // MARK: - State
    
    private enum LayoutVariant {
        case twoRow, finishedRow, accumulatedRow, vacationRow, holidayRow
    }
    private var currentVariant: LayoutVariant = .twoRow
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Configure
    
    func configure(status: WorkStatusEntity, data: HomeEntity) {
        containerView.backgroundColor = AppColor.Container.primary
        
        switch (data.type, status) {
            
        case (.none, _):
            renderHolidayRow()
            
        case (.vacation, .finished):
            renderVacationRow(dailyPay: data.dailyPay)
            
        case (.work, .finished):
            let clockInStr  = data.clockInTime?.displayString  ?? "--:--"
            let clockOutStr = data.clockOutTime?.displayString ?? "--:--"
            renderFinishedRow(
                dailyWage: data.dailyPay,
                timeValue: "\(clockInStr) - \(clockOutStr)",
                tappable: false
            )
            
        case (.vacation, _):
            renderVacationRow(dailyPay: data.dailyPay)
            
        default:
            let clockInStr  = data.clockInTime?.displayString  ?? "--:--"
            let clockOutStr = data.clockOutTime?.displayString ?? "--:--"
            renderTwoRow(
                dailyWage: data.dailyPay,
                timeValue: "\(clockInStr) - \(clockOutStr)"
            )
        }
    }
    
    /// 근무완료 1 전용 — WorkEndBottomIndicator 내부에서 호출
    /// "누적 월급" 타이틀 + 블러 오버레이 적용
    func configureForEndIndicator(data: HomeEntity) {
        
        switch data.type {
        case .none:
            renderHolidayRow()
        case .vacation:
            renderVacationRow(dailyPay: data.dailyPay)
        case .work:
            let clockInStr  = data.clockInTime?.displayString  ?? "--:--"
            let clockOutStr = data.clockOutTime?.displayString ?? "--:--"
            renderAccumulatedRow(
                accumulatedWage: data.dailyPay,
                timeValue: "\(clockInStr) - \(clockOutStr)"
            )
        }
    }
    
    // MARK: - Render
    
    private func renderTwoRow(dailyWage: Int, timeValue: String) {
        setRowsHidden(wage: false, accumulated: true, divider: false,
                      time: false, finished: true, vacation: true, holiday: true)
        
        wageRowView.updateValue(formattedWage(dailyWage))
        timeRowView.updateValue(timeValue)
        
        guard currentVariant != .twoRow else { return }
        currentVariant = .twoRow
        applyBottomRowConstraints(bottomRow: timeRowView, wageRow: wageRowView)
    }
    
    private func renderFinishedRow(dailyWage: Int, timeValue: String, tappable: Bool) {
        setRowsHidden(wage: false, accumulated: true, divider: false,
                      time: true, finished: false, vacation: true, holiday: true)
        
        finishedTimeRowView.showChevron(tappable)
        wageRowView.updateValue(formattedWage(dailyWage))
        finishedTimeRowView.updateValue(timeValue)
        finishedTimeRowView.onTap = tappable ? { [weak self] in self?.onTapTimeRow?() } : nil
        
        guard currentVariant != .finishedRow else { return }
        currentVariant = .finishedRow
        applyBottomRowConstraints(bottomRow: finishedTimeRowView, wageRow: wageRowView)
    }
    
    /// 근무완료1 전용: 누적 월급 행 + 탭 가능한 시간 행
    private func renderAccumulatedRow(accumulatedWage: Int, timeValue: String) {
        setRowsHidden(wage: true, accumulated: false, divider: false,
                      time: true, finished: false, vacation: true, holiday: true)
        
        accumulatedWageRowView.updateValue(formattedWage(accumulatedWage))
        finishedTimeRowView.showChevron(true)
        finishedTimeRowView.updateValue(timeValue)
        finishedTimeRowView.onTap = { [weak self] in self?.onTapTimeRow?() }
        
        guard currentVariant != .accumulatedRow else { return }
        currentVariant = .accumulatedRow
        applyBottomRowConstraints(bottomRow: finishedTimeRowView, wageRow: accumulatedWageRowView)
    }
    
    private func renderHolidayRow() {
        setRowsHidden(wage: true, accumulated: true, divider: true,
                      time: true, finished: true, vacation: true, holiday: false)
        
        guard currentVariant != .holidayRow else { return }
        currentVariant = .holidayRow
        applyOneRowConstraints(row: holidayRowView)
    }
    
    private func renderVacationRow(dailyPay: Int) {
        setRowsHidden(wage: false, accumulated: true, divider: false,
                      time: true, finished: true, vacation: false, holiday: true)
        
        wageRowView.updateValue(formattedWage(dailyPay))
        
        guard currentVariant != .vacationRow else { return }
        currentVariant = .vacationRow
        applyBottomRowConstraints(bottomRow: vacationTimeRowView, wageRow: wageRowView)
    }
    
    // MARK: - Helpers
    
    private func setRowsHidden(
        wage: Bool, accumulated: Bool, divider: Bool,
        time: Bool, finished: Bool, vacation: Bool, holiday: Bool
    ) {
        wageRowView.isHidden          = wage
        accumulatedWageRowView.isHidden = accumulated
        dividerView.isHidden          = divider
        timeRowView.isHidden          = time
        finishedTimeRowView.isHidden  = finished
        vacationTimeRowView.isHidden  = vacation
        holidayRowView.isHidden       = holiday
    }
    
    private func formattedWage(_ amount: Int) -> String {
        "\(AppNumberFormatter.decimalString(from: amount))원"
    }
    
    // MARK: - Layout
    
    private func setupUI() {
        addSubview(containerView)
        
        containerView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        containerView.addSubViews([
            wageRowView, accumulatedWageRowView, dividerView,
            timeRowView, finishedTimeRowView, vacationTimeRowView, holidayRowView
        ])
        
        applyBottomRowConstraints(bottomRow: timeRowView, wageRow: wageRowView)
    }
    
    private func applyBottomRowConstraints(bottomRow: UIView, wageRow: UIView) {
        // 높이=0으로 layout에서 배제
        holidayRowView.snp.remakeConstraints {
            $0.top.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(0)
        }
        
        wageRowView.snp.remakeConstraints {
            let isActive = wageRow === wageRowView
            $0.top.horizontalEdges.equalToSuperview().inset(16)
            if !isActive { $0.height.equalTo(0) }
        }
        accumulatedWageRowView.snp.remakeConstraints {
            let isActive = wageRow === accumulatedWageRowView
            $0.top.horizontalEdges.equalToSuperview().inset(16)
            if !isActive { $0.height.equalTo(0) }
        }
        
        dividerView.snp.remakeConstraints {
            $0.top.equalTo(wageRow.snp.bottom).offset(14)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(1)
        }
        
        [timeRowView, finishedTimeRowView, vacationTimeRowView].forEach { row in
            row.snp.remakeConstraints {
                $0.top.equalTo(dividerView.snp.bottom).offset(14)
                $0.horizontalEdges.equalToSuperview().inset(16)
                if row === bottomRow { $0.bottom.equalToSuperview().inset(16) }
            }
        }
    }
    
    private func applyOneRowConstraints(row: UIView) {
        wageRowView.snp.remakeConstraints {
            $0.top.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(0)
        }
        accumulatedWageRowView.snp.remakeConstraints {
            $0.top.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(0)
        }
        dividerView.snp.remakeConstraints {
            $0.top.equalTo(wageRowView.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(0)
        }
        [timeRowView, finishedTimeRowView, vacationTimeRowView].forEach {
            $0.snp.remakeConstraints {
                $0.top.equalTo(dividerView.snp.bottom)
                $0.horizontalEdges.equalToSuperview().inset(16)
                $0.height.equalTo(0)
            }
        }
        row.snp.remakeConstraints {
            $0.edges.equalToSuperview().inset(16)
        }
    }
}
