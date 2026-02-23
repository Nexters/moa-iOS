//
//  WorkingContentView.swift
//  Moa
//

import UIKit
import SnapKit

// MARK: - WorkingContentViewDelegate

protocol WorkingContentViewDelegate: AnyObject {
    func workingContentViewDidTapScheduleAdjust(_ view: WorkingContentView)
    func workingContentViewDidTapExtendWork(_ view: WorkingContentView)
    func workingContentViewDidTapTimeRow(_ view: WorkingContentView)
    func workingContentViewDidTapConfirm(_ view: WorkingContentView)
}

// MARK: - WorkingContentView

final class WorkingContentView: UIView {

    weak var delegate: WorkingContentViewDelegate?

    // MARK: - UI

    private var workingType: WorkingType

    private lazy var earningsStackView = EarningsStackView(workingType: workingType)

    private lazy var workingStatusView: WorkingStatusView = {
        let view = WorkingStatusView(workingType: workingType)
        view.delegate = self
        return view
    }()

    private lazy var workEndIndicator: WorkEndBottomIndicator = {
        let view = WorkEndBottomIndicator()
        view.delegate = self
        view.isHidden = true
        return view
    }()

    // MARK: - State

    private var dailyPay: Int                    = 0
    private var totalWorkSeconds: Int            = 0
    private var isFinished: Bool                 = false
    private var endTime: TimeIndicatorEntity     = .from(hour: 18, minute: 0)
    private var workedEarnings: Int              = 0   // 이번달 누적 월급

    // MARK: - Init

    init(workingType: WorkingType = .work) {
        self.workingType = workingType
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Setup

    private func setupUI() {
        addSubViews([earningsStackView, workingStatusView, workEndIndicator])

        earningsStackView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(workingStatusView.snp.top).offset(40)
        }
        workingStatusView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
            $0.bottom.equalTo(safeAreaLayoutGuide)
        }
        workEndIndicator.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalTo(snp.centerY)
        }
    }

    // MARK: - Configure

    func configure(
        dailyPay:    Int,
        startTime:   TimeIndicatorEntity,
        endTime:     TimeIndicatorEntity,
        startedAt:   Date,
        workingType: WorkingType,
        status:      WorkStatus,
        data:        HomeEntity
    ) {
        let newIsFinished         = (status == .workFinished)
        self.isFinished           = newIsFinished
        self.dailyPay             = dailyPay
        self.totalWorkSeconds     = max(1, (endTime.totalMinutes - startTime.totalMinutes) * 60)
        self.endTime              = endTime
        self.workedEarnings       = data.workedEarnings

        if self.workingType != workingType {
            self.workingType = workingType
            applyWorkingType(workingType)
        }

        if newIsFinished {
            // 근무완료 1: 말풍선·성장 완전 차단
            earningsStackView.configure(
                amount:     dailyPay,
                startedAt:  startedAt,
                isFinished: true,
                context:    nil
            )
            workingStatusView.isHidden = true
        } else {
            workingStatusView.isHidden = false
            let elapsed = max(0, Int(Date().timeIntervalSince(startedAt)))
            earningsStackView.configure(
                amount:     earnedAmount(elapsed: elapsed),
                startedAt:  startedAt,
                isFinished: false,
                context:    makeTooltipContext()
            )
            workingStatusView.configure(startTime: startTime, endTime: endTime, startedAt: startedAt)
        }

        workEndIndicator.isHidden = !newIsFinished
        if newIsFinished {
            workEndIndicator.configure(status: status, data: data)
        }
    }

    // MARK: - Tick

    func tick() {
        guard !isFinished else { return }
        let elapsed = workingStatusView.elapsedSeconds()
        earningsStackView.updateAmount(earnedAmount(elapsed: elapsed))
        // cheer 문구는 매 tick 남은 시간이 바뀌므로 context 갱신
        earningsStackView.updateContext(makeTooltipContext())
        workingStatusView.tick()
    }

    // MARK: - Public API

    func startAnimations() {
        guard !isFinished else { return }
        earningsStackView.startAnimations()
    }

    func stopAnimations() {
        earningsStackView.stopAnimations()
    }

    // MARK: - Private

    private func earnedAmount(elapsed: Int) -> Int {
        guard totalWorkSeconds > 0 else { return 0 }
        return Int(Double(dailyPay) * Double(elapsed) / Double(totalWorkSeconds))
    }

    private func applyWorkingType(_ type: WorkingType) {
        earningsStackView.updateWorkingType(type)
        workingStatusView.updateWorkingType(type)
    }

    private func makeTooltipContext() -> TooltipContext {
        TooltipContext(
            workingType:    workingType,
            workedEarnings: workedEarnings,
            endTime:        endTime
        )
    }
}

// MARK: - WorkingStatusViewDelegate

extension WorkingContentView: WorkingStatusViewDelegate {
    func workingStatusViewDidTapScheduleAdjust(_ view: WorkingStatusView) {
        delegate?.workingContentViewDidTapScheduleAdjust(self)
    }
}

// MARK: - WorkEndBottomIndicatorDelegate

extension WorkingContentView: WorkEndBottomIndicatorDelegate {
    func workEndBottomIndicatorDidTapExtendWork(_ view: WorkEndBottomIndicator) {
        delegate?.workingContentViewDidTapExtendWork(self)
    }
    func workEndBottomIndicatorDidTapTimeRow(_ view: WorkEndBottomIndicator) {
        delegate?.workingContentViewDidTapTimeRow(self)
    }
    func workEndBottomIndicatorDidTapConfirm(_ view: WorkEndBottomIndicator) {
        delegate?.workingContentViewDidTapConfirm(self)
    }
}
