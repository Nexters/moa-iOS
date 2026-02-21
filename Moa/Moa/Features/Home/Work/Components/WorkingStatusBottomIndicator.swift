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
    
    private let workingType: WorkingType
    
    private lazy var statusBadgeView: StatusBadgeView = {
        return StatusBadgeView(type: workingType.badgeType)
    }()

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
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .equalSpacing
        return stack
    }()

    private lazy var progressBar: WorkProgressBar = {
        return WorkProgressBar(workingType: workingType)
    }()

    // MARK: - Properties

    private var startedAt: Date = Date()
    private var scheduledStart: Date = Date()
    private var scheduledEnd: Date = Date()

    // MARK: - Init

    init(workingType: WorkingType) {
        self.workingType = workingType
        super.init(frame: .zero)
        
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupUI() {
        
        addSubViews([
            statusBadgeView,
            timerContentView,
            progressBar
        ])

        statusBadgeView.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
        }

        timerContentView.snp.makeConstraints {
            $0.top.equalTo(statusBadgeView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
        }

        progressBar.snp.makeConstraints {
            $0.top.equalTo(timerContentView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(48)
        }
    }

    // MARK: - Configure

    /// 뷰 초기 데이터 설정
    func configure(
        startTime: String,
        endTime: String,
        startedAt: Date
    ) {
        self.startedAt = startedAt

        // 시간 파싱
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "ko_KR")
        scheduledStart = formatter.date(from: startTime) ?? startedAt
        scheduledEnd = formatter.date(from: endTime) ?? startedAt

        // 진행률 바 시간 라벨 설정
        progressBar.configure(startTime: startTime, endTime: endTime)

        // 초기 업데이트
        tick()
    }

    // MARK: - Public API

    /// 매 초마다 호출하여 타이머와 진행률 업데이트
    func tick() {
        updateTimer()
        updateProgress()
    }

    /// 뱃지 상태 변경
    func updateBadgeType(_ type: BadgeType) {
        statusBadgeView.updateType(type)
    }

    // MARK: - Private Update

    private func updateTimer() {
        let elapsed = max(0, Int(Date().timeIntervalSince(startedAt)))
        timerView.setElapsed(seconds: elapsed)
    }

    private func updateProgress() {
        let calendar = Calendar.current
        let now = Date()

        let startComponents = calendar.dateComponents([.hour, .minute], from: scheduledStart)
        let endComponents = calendar.dateComponents([.hour, .minute], from: scheduledEnd)

        guard
            let todayStart = calendar.date(
                bySettingHour: startComponents.hour ?? 9,
                minute: startComponents.minute ?? 0,
                second: 0,
                of: now
            ),
            let todayEnd = calendar.date(
                bySettingHour: endComponents.hour ?? 18,
                minute: endComponents.minute ?? 0,
                second: 0,
                of: now
            )
        else { return }

        let totalDuration = todayEnd.timeIntervalSince(todayStart)
        let elapsed = now.timeIntervalSince(todayStart)

        guard totalDuration > 0 else { return }

        let progress = max(0, min(1, elapsed / totalDuration))
        progressBar.setProgress(progress)
    }

    // MARK: - Action

    @objc
    private func didTapSchedule() {
        delegate?.workingStatusViewDidTapScheduleAdjust(self)
    }
}
