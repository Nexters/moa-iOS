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

    private lazy var wageRowView = KeyValueRowView(type: .wageRow(wage: 0))

    private let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColor.Divider.secondary
        return view
    }()

    /// idle / working (근무일): 탭 가능, chevron O
    private lazy var timeRowView: KeyValueRowView = {
        let row = KeyValueRowView(type: .timeRow(startTime: "", endTime: ""), showsChevron: true)
        row.onTap = { [weak self] in self?.onTapTimeRow?() }
        return row
    }()

    /// 근무완료 1 / 최종완료 (근무일): chevron O or X, tappable 여부 동적 결정
    private lazy var finishedTimeRowView: KeyValueRowView = {
        let row = KeyValueRowView(type: .timeRow(startTime: "", endTime: ""), showsChevron: true)
        return row
    }()

    /// 휴가 / 최종완료(휴가): "휴가" 고정, chevron X, 탭 불가
    private lazy var vacationTimeRowView = KeyValueRowView(
        type: .customRow(key: "근무 시간", value: "휴가"),
        showsChevron: false
    )

    // MARK: - State

    private enum LayoutVariant { case twoRow, finishedRow, vacationRow }
    private var currentVariant: LayoutVariant = .twoRow

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Configure

    /// 일반 상태별 렌더링
    /// - idle / working: 탭 가능
    /// - finished (최종완료): 탭 불가
    func configure(status: WorkStatus, data: HomeEntity) {
        switch (data.type, status) {

        case (.none, .finished), (.vacation, .finished):
            renderVacationRow(dailyPay: data.dailyPay)

        // 최종완료 — 근무일: chevron O, 탭 불가
        case (.work, .finished):
            let clockInStr  = data.clockInTime?.displayString  ?? "--:--"
            let clockOutStr = data.clockOutTime?.displayString ?? "--:--"
            renderFinishedRow(
                dailyWage: data.dailyPay,
                timeValue: "\(clockInStr) - \(clockOutStr)",
                tappable: false
            )

        case (.none, _), (.vacation, _):
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
    /// 항상 tappable: true (탭 → 실제 근무 시간 수정 시트)
    /// containerView alpha 0.6 적용
    func configureForEndIndicator(data: HomeEntity) {
        containerView.backgroundColor = AppColor.Container.primary.withAlphaComponent(0.6)

        switch data.type {
        case .none, .vacation:
            renderVacationRow(dailyPay: data.dailyPay)
        case .work:
            let clockInStr  = data.clockInTime?.displayString  ?? "--:--"
            let clockOutStr = data.clockOutTime?.displayString ?? "--:--"
            renderFinishedRow(
                dailyWage: data.dailyPay,
                timeValue: "\(clockInStr) - \(clockOutStr)",
                tappable: true
            )
        }
    }

    // MARK: - Render

    private func renderTwoRow(dailyWage: Int, timeValue: String) {
        wageRowView.isHidden         = false
        dividerView.isHidden         = false
        timeRowView.isHidden         = false
        finishedTimeRowView.isHidden = true
        vacationTimeRowView.isHidden = true

        wageRowView.updateValue(formattedWage(dailyWage))
        timeRowView.updateValue(timeValue)

        guard currentVariant != .twoRow else { return }
        currentVariant = .twoRow
        applyBottomRowConstraints(bottomRow: timeRowView)
    }

    private func renderFinishedRow(dailyWage: Int, timeValue: String, tappable: Bool) {
        wageRowView.isHidden         = false
        dividerView.isHidden         = false
        timeRowView.isHidden         = true
        finishedTimeRowView.isHidden = false
        vacationTimeRowView.isHidden = true
        
        finishedTimeRowView.showChevron(tappable)

        wageRowView.updateValue(formattedWage(dailyWage))
        finishedTimeRowView.updateValue(timeValue)
        finishedTimeRowView.onTap = tappable
            ? { [weak self] in self?.onTapTimeRow?() }
            : nil

        guard currentVariant != .finishedRow else { return }
        currentVariant = .finishedRow
        applyBottomRowConstraints(bottomRow: finishedTimeRowView)
    }

    private func renderVacationRow(dailyPay: Int) {
        wageRowView.isHidden         = false
        dividerView.isHidden         = false
        timeRowView.isHidden         = true
        finishedTimeRowView.isHidden = true
        vacationTimeRowView.isHidden = false

        wageRowView.updateValue(formattedWage(dailyPay))

        guard currentVariant != .vacationRow else { return }
        currentVariant = .vacationRow
        applyBottomRowConstraints(bottomRow: vacationTimeRowView)
    }

    // MARK: - Helpers

    private func formattedWage(_ amount: Int) -> String {
        "\(AppNumberFormatter.decimalString(from: amount))원"
    }

    // MARK: - Layout

    private func setupUI() {
        addSubview(containerView)
        containerView.snp.makeConstraints { $0.edges.equalToSuperview() }
        containerView.addSubViews([
            wageRowView, dividerView,
            timeRowView, finishedTimeRowView, vacationTimeRowView
        ])
        applyBottomRowConstraints(bottomRow: timeRowView)
    }

    private func applyBottomRowConstraints(bottomRow: UIView) {
        wageRowView.snp.remakeConstraints {
            $0.top.horizontalEdges.equalToSuperview().inset(16)
        }
        dividerView.snp.remakeConstraints {
            $0.top.equalTo(wageRowView.snp.bottom).offset(14)
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
}
