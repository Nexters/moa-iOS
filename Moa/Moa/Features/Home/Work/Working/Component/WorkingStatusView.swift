//
//  WorkingStatusView.swift
//  Moa
//
//  Created by 정도현 on 2/18/26.
//

import UIKit
import SnapKit

// MARK: - WorkingStatusViewDelegate

protocol WorkingStatusViewDelegate: AnyObject {
    func workingStatusViewDidTapScheduleAdjust(_ view: WorkingStatusView)
}

// MARK: - WorkingStatusView

final class WorkingStatusView: UIView {

    // MARK: - Delegate

    weak var delegate: WorkingStatusViewDelegate?

    // MARK: - UI

    private lazy var statusBadgeView = StatusBadgeView(type: .working)
    private let timerView = WorkTimerView()

    private lazy var scheduleButton: AppButton = {
        let button = AppButton()
        button.setTitle("일정 조정", for: .normal)
        button.applyStyle(
            .tertiary(
                font: AppTypography.b1_600.font(),
                verticalPadding: 6,
                horizontalPadding: 14
            )
        )
        button.addTarget(self, action: #selector(didTapSchedule), for: .touchUpInside)
        return button
    }()

    private lazy var timerContentView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [timerView, scheduleButton])
        stack.axis         = .horizontal
        stack.alignment    = .center
        stack.distribution = .equalSpacing
        return stack
    }()

    private var progressBar: WorkProgressBar

    // MARK: - State
    //
    // 경과 시간 계산 방식:
    //   elapsed = Date().timeIntervalSince(startedAt)
    //
    //   resolveAutoStatus에서 startedAt = 실제 clockIn Date (오늘 09:00 등)
    //   → 예) clockIn 09:00, 현재 17:00
    //         elapsed = 17:00 - 09:00 = 28800초 = 8시간
    //
    //   수동 출근 버튼: startedAt = Date() (누른 시점)

    private var startedAt:             Date = Date()
    private var scheduledStartMinutes: Int  = 0
    private var scheduledEndMinutes:   Int  = 0

    // MARK: - Init

    init(workingType: WorkingType) {
        self.progressBar = WorkProgressBar(workingType: workingType)
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Setup

    private func setupUI() {
        addSubViews([statusBadgeView, timerContentView, progressBar])

        scheduleButton.snp.makeConstraints { $0.height.equalTo(36) }

        statusBadgeView.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
        }
        timerContentView.snp.makeConstraints {
            $0.top.equalTo(statusBadgeView.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
        }
        progressBar.snp.makeConstraints {
            $0.top.equalTo(timerContentView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(48)
        }
    }

    // MARK: - Configure

    func configure(
        startTime: TimeIndicatorEntity,
        endTime:   TimeIndicatorEntity,
        startedAt: Date
    ) {
        self.startedAt             = startedAt
        self.scheduledStartMinutes = startTime.hour * 60 + startTime.minute
        self.scheduledEndMinutes   = endTime.hour   * 60 + endTime.minute

        progressBar.configure(
            startTime: startTime.displayString,
            endTime:   endTime.displayString
        )
        tick()
    }

    // MARK: - Public API

    /// 1초마다 WorkingContentView.tick()에서 호출
    func tick() {
        updateTimer()
        updateProgress()
    }

    func updateBadgeType(_ type: BadgeType) {
        statusBadgeView.updateType(type)
    }

    /// work ↔ vacation 전환 시 badge + progressBar 색상 동시 업데이트
    func updateWorkingType(_ type: WorkingType) {
        statusBadgeView.updateType(type.badgeType)
        progressBar.updateBarColor(type)
    }

    /// 금액 계산용 — WorkingContentView에서 호출
    func elapsedSeconds() -> Int {
        max(0, Int(Date().timeIntervalSince(startedAt)))
    }

    // MARK: - Private

    private func updateTimer() {
        timerView.setElapsed(seconds: elapsedSeconds())
    }

    private func updateProgress() {
        let calendar   = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: Date())
        let nowMinutes = (components.hour ?? 0) * 60 + (components.minute ?? 0)

        let totalMinutes   = scheduledEndMinutes - scheduledStartMinutes
        guard totalMinutes > 0 else { return }

        let elapsedMinutes = nowMinutes - scheduledStartMinutes
        let progress       = max(0, min(1, Double(elapsedMinutes) / Double(totalMinutes)))
        progressBar.setProgress(progress)
    }

    // MARK: - Action

    @objc private func didTapSchedule() {
        delegate?.workingStatusViewDidTapScheduleAdjust(self)
    }
}
