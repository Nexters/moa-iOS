//
//  WorkingStatusView.swift
//  Moa
//

import UIKit
import SnapKit

protocol WorkingStatusViewDelegate: AnyObject {
    func workingStatusViewDidTapScheduleAdjust(_ view: WorkingStatusView)
}

final class WorkingStatusView: UIView {

    weak var delegate: WorkingStatusViewDelegate?

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

    private var startedAt:             Date = Date()
    private var scheduledStartMinutes: Int  = 0
    private var scheduledEndMinutes:   Int  = 0

    init(workingType: WorkingType) {
        self.progressBar = WorkProgressBar(workingType: workingType)
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        addSubViews([statusBadgeView, timerContentView, progressBar])

        scheduleButton.snp.makeConstraints {
            $0.height.equalTo(36)
        }
        statusBadgeView.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            // 뱃지 최소 높이 보장 → 압축되어도 텍스트가 찌그러지지 않음
            $0.height.greaterThanOrEqualTo(28)
        }
        timerContentView.snp.makeConstraints {
            $0.top.equalTo(statusBadgeView.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
        }
        progressBar.snp.makeConstraints {
            $0.top.equalTo(timerContentView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }

    func configure(
        startTime: TimeIndicatorEntity,
        endTime:   TimeIndicatorEntity,
        startedAt: Date
    ) {
        self.startedAt             = startedAt
        self.scheduledStartMinutes = startTime.hour * 60 + startTime.minute
        self.scheduledEndMinutes   = endTime.hour   * 60 + endTime.minute
        progressBar.configure(startTime: startTime.displayString, endTime: endTime.displayString)
        tick()
    }

    func tick() {
        updateTimer()
        updateProgress()
    }

    func updateBadgeType(_ type: WorkBadgeType) {
        statusBadgeView.updateType(type)
    }

    func updateWorkingType(_ type: WorkingType) {
        statusBadgeView.updateType(type.badgeType)
        progressBar.updateBarColor(type)
    }

    func elapsedSeconds() -> Int {
        max(0, Int(Date().timeIntervalSince(startedAt)))
    }

    private func updateTimer() {
        timerView.setElapsed(seconds: elapsedSeconds())
    }

    private func updateProgress() {
        let comps      = Calendar.current.dateComponents([.hour, .minute], from: Date())
        let nowMinutes = (comps.hour ?? 0) * 60 + (comps.minute ?? 0)
        let total      = scheduledEndMinutes - scheduledStartMinutes
        guard total > 0 else { return }
        let progress = max(0, min(1, Double(nowMinutes - scheduledStartMinutes) / Double(total)))
        progressBar.setProgress(progress)
    }

    @objc private func didTapSchedule() {
        delegate?.workingStatusViewDidTapScheduleAdjust(self)
    }
}
