//
//  WorkMainSummaryView.swift
//  Moa
//
//  Created by 정도현 on 2/2/26.
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

    // beforeWork / afterWork — 탭 가능, chevron 있음
    private lazy var timeRowView: KeyValueRowView = {
        let row = KeyValueRowView(type: .timeRow(startTime: "", endTime: ""), showsChevron: true)
        row.onTap = { [weak self] in self?.onTapTimeRow?() }
        return row
    }()

    // onVacation 완료 전용 — "휴가" 텍스트, 탭 불가, chevron 없음
    private lazy var vacationTimeRowView = KeyValueRowView(
        type: .customRow(key: "근무", value: "휴가"),
        showsChevron: false
    )

    // holiday 전용 — 탭 불가, chevron 없음
    private lazy var holidayRowView = KeyValueRowView(
        type: .customRow(key: "근무", value: "근무 예정 없음"),
        showsChevron: false
    )

    // MARK: - State

    private enum LayoutVariant { case twoRow, vacationRow, oneRow }
    private var currentVariant: LayoutVariant = .twoRow

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Configure

    func configure(with display: HomeDisplayData) {
        switch display.scheduleStatus {
        case .holiday:
            renderOneRow()

        case .onVacation:
            // 휴가 완료 카드 — 시간 대신 "휴가" 표시, 탭 불가
            renderVacationRow(dailyWage: display.dailyWage)

        default:
            // beforeWork / afterWork
            let timeValue = "\(display.scheduledClockIn.displayString) - \(display.scheduledClockOut.displayString)"
            renderTwoRow(
                dailyWage: display.dailyWage,
                timeValue: timeValue,
                prefix:    display.scheduleStatus.wagePrefix
            )
        }
    }

    // MARK: - Render

    private func renderTwoRow(dailyWage: Int, timeValue: String, prefix: String?) {
        wageRowView.isHidden         = false
        dividerView.isHidden         = false
        timeRowView.isHidden         = false
        vacationTimeRowView.isHidden = true
        holidayRowView.isHidden      = true

        let formatted = AppNumberFormatter.decimalString(from: dailyWage)
        wageRowView.updateValue("\(prefix ?? "")\(formatted)원")
        timeRowView.updateValue(timeValue)

        guard currentVariant != .twoRow else { return }
        currentVariant = .twoRow
        applyTwoRowConstraints(bottomRow: timeRowView)
    }

    private func renderVacationRow(dailyWage: Int) {
        wageRowView.isHidden         = false
        dividerView.isHidden         = false
        timeRowView.isHidden         = true
        vacationTimeRowView.isHidden = false
        holidayRowView.isHidden      = true

        let formatted = AppNumberFormatter.decimalString(from: dailyWage)
        wageRowView.updateValue("\(formatted)원")

        guard currentVariant != .vacationRow else { return }
        currentVariant = .vacationRow
        applyTwoRowConstraints(bottomRow: vacationTimeRowView)
    }

    private func renderOneRow() {
        wageRowView.isHidden         = true
        dividerView.isHidden         = true
        timeRowView.isHidden         = true
        vacationTimeRowView.isHidden = true
        holidayRowView.isHidden      = false

        guard currentVariant != .oneRow else { return }
        currentVariant = .oneRow
        applyOneRowConstraints()
    }

    // MARK: - Layout

    private func setupUI() {
        addSubview(containerView)
        containerView.snp.makeConstraints { $0.edges.equalToSuperview() }
        containerView.addSubViews([wageRowView, dividerView, timeRowView, vacationTimeRowView, holidayRowView])
        applyTwoRowConstraints(bottomRow: timeRowView)
    }

    private func applyTwoRowConstraints(bottomRow: UIView) {
        wageRowView.snp.remakeConstraints {
            $0.top.horizontalEdges.equalToSuperview().inset(16)
        }
        dividerView.snp.remakeConstraints {
            $0.top.equalTo(wageRowView.snp.bottom).offset(14)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(1)
        }
        // 실제 보이는 bottomRow에 bottom 제약 연결
        [timeRowView, vacationTimeRowView].forEach { row in
            row.snp.remakeConstraints {
                $0.top.equalTo(dividerView.snp.bottom).offset(14)
                $0.horizontalEdges.equalToSuperview().inset(16)
                if row === bottomRow { $0.bottom.equalToSuperview().inset(16) }
            }
        }
        holidayRowView.snp.remakeConstraints { $0.edges.equalToSuperview().inset(16) }
    }

    private func applyOneRowConstraints() {
        holidayRowView.snp.remakeConstraints    { $0.edges.equalToSuperview().inset(16) }
        wageRowView.snp.remakeConstraints       { $0.top.horizontalEdges.equalToSuperview().inset(16) }
        dividerView.snp.remakeConstraints       { $0.top.horizontalEdges.equalToSuperview(); $0.height.equalTo(0) }
        [timeRowView, vacationTimeRowView].forEach {
            $0.snp.remakeConstraints { $0.top.horizontalEdges.equalToSuperview().inset(16) }
        }
    }
}
