//
//  WorkingContentView.swift
//  Moa
//
//  Created by 정도현 on 2/18/26.
//

import UIKit
import SnapKit

// MARK: - WorkingContentViewDelegate

protocol WorkingContentViewDelegate: AnyObject {
    func workingContentViewDidTapScheduleAdjust(_ view: WorkingContentView)
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

    // MARK: - State

    private var hourlyWage: Int = 0

    // MARK: - Init

    init(workingType: WorkingType = .work) {
        self.workingType = workingType
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Setup

    private func setupUI() {
        addSubViews([earningsStackView, workingStatusView])

        earningsStackView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(workingStatusView.snp.top).offset(40)
        }
        workingStatusView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
            $0.bottom.equalTo(safeAreaLayoutGuide)
        }
    }

    // MARK: - Configure

    func configure(
        todayAmount: Int,
        hourlyWage: Int,
        startTime: TimeIndicatorEntity,
        endTime: TimeIndicatorEntity,
        startedAt: Date,
        workingType: WorkingType
    ) {
        self.hourlyWage = hourlyWage

        if self.workingType != workingType {
            self.workingType = workingType
            applyWorkingType(workingType)
        }

        earningsStackView.configure(amount: todayAmount)
        workingStatusView.configure(startTime: startTime, endTime: endTime, startedAt: startedAt)
    }

    // MARK: - Tick (1초마다 WorkViewController Timer에서 호출)

    func tick() {
        let elapsed = workingStatusView.elapsedSeconds()
        let earned  = Int(Double(hourlyWage) * Double(elapsed) / 3600.0)
        earningsStackView.updateAmount(earned)
        workingStatusView.tick()
    }

    // MARK: - Public API

    func startAnimations() { earningsStackView.startAnimations() }
    func stopAnimations()   { earningsStackView.stopAnimations() }

    // MARK: - Private

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
