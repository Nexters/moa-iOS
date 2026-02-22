//
//  WorkingContentView.swift
//  Moa
//

import UIKit
import SnapKit

// MARK: - WorkingContentViewDelegate

protocol WorkingContentViewDelegate: AnyObject {
    /// working: "일정 조정" 탭
    func workingContentViewDidTapScheduleAdjust(_ view: WorkingContentView)
    /// finished: "더 일할게요" 탭
    func workingContentViewDidTapExtendWork(_ view: WorkingContentView)
    /// finished: 근무시간 행 탭 → 출퇴근 수정 시트
    func workingContentViewDidTapTimeRow(_ view: WorkingContentView)
    /// finished: "완료" 탭 → 최종 완료 페이지
    func workingContentViewDidTapConfirm(_ view: WorkingContentView)
}

// MARK: - WorkingContentView

final class WorkingContentView: UIView {

    // MARK: - Delegate

    weak var delegate: WorkingContentViewDelegate?

    // MARK: - UI

    private var workingType: WorkingType

    private lazy var earningsStackView = EarningsStackView(workingType: workingType)

    private lazy var workingStatusView: WorkingStatusView = {
        let view = WorkingStatusView(workingType: workingType)
        view.delegate = self
        return view
    }()

    /// finished 상태 오버레이
    private lazy var workEndIndicator: WorkEndBottomIndicator = {
        let view = WorkEndBottomIndicator()
        view.delegate = self
        view.isHidden = true
        return view
    }()

    // MARK: - State

    private var dailyPay: Int         = 0
    private var totalWorkSeconds: Int = 0

    /// finished: true → tick()에서 금액 업데이트 중단, 스택 애니메이션 중지
    private var isFinished: Bool = false

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
        let newIsFinished = (status == .finished)
        self.isFinished       = newIsFinished
        self.dailyPay         = dailyPay
        self.totalWorkSeconds = max(1, (endTime.totalMinutes - startTime.totalMinutes) * 60)

        if self.workingType != workingType {
            self.workingType = workingType
            applyWorkingType(workingType)
        }

        let elapsed = max(0, Int(Date().timeIntervalSince(startedAt)))

        if newIsFinished {
            // finished: dailyPay 전액 고정 표시, 애니메이션 중지
            earningsStackView.configure(amount: dailyPay, startedAt: startedAt)
            earningsStackView.stopAnimations()
        } else {
            let earnedSoFar = earnedAmount(elapsed: elapsed)
            earningsStackView.configure(amount: earnedSoFar, startedAt: startedAt)
        }

        workingStatusView.configure(startTime: startTime, endTime: endTime, startedAt: startedAt)

        workEndIndicator.isHidden = !newIsFinished
        if newIsFinished {
            workEndIndicator.configure(status: status, data: data)
        }
    }

    // MARK: - Tick (1초마다 WorkViewController Timer에서 호출)

    func tick() {
        // finished: 금액 고정 — 타이머 경과 시간만 업데이트
        if isFinished {
            workingStatusView.tick()
            return
        }
        let elapsed = workingStatusView.elapsedSeconds()
        let earned  = earnedAmount(elapsed: elapsed)
        earningsStackView.updateAmount(earned)
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
