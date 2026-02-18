//
//  WorkProgressBar.swift
//  Moa
//
//  Created by 정도현 on 2/18/26.
//

import UIKit
import SnapKit

// MARK: - WorkProgressBar

final class WorkProgressBar: UIView {
    
    private let workingType: WorkingType
    
    private let trackView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColor.IconAndText.disabled
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        return view
    }()

    private lazy var fillView: UIView = {
        let view = UIView()
        view.backgroundColor = workingType.barColor
        view.layer.cornerRadius = 5
        return view
    }()

    private let startTimeLabel: StyledLabel = {
        let label = StyledLabel()
        label.setStyle(.init(
            typography: AppTypography.b2_400,
            color: AppColor.IconAndText.mediumEmphasis
        ))
        return label
    }()

    private let endTimeLabel: StyledLabel = {
        let label = StyledLabel()
        label.setStyle(.init(
            typography: AppTypography.b2_400,
            color: AppColor.IconAndText.mediumEmphasis
        ))
        return label
    }()

    private var fillWidthConstraint: Constraint?

    init(workingType: WorkingType) {
        self.workingType = workingType
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubViews([trackView, startTimeLabel, endTimeLabel])
        trackView.addSubview(fillView)

        trackView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(10)
        }

        fillView.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            fillWidthConstraint = $0.width.equalTo(0).constraint
        }

        startTimeLabel.snp.makeConstraints {
            $0.top.equalTo(trackView.snp.bottom).offset(4)
            $0.leading.equalToSuperview()
            $0.bottom.equalToSuperview()
        }

        endTimeLabel.snp.makeConstraints {
            $0.top.equalTo(trackView.snp.bottom).offset(4)
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }

    func configure(startTime: String, endTime: String) {
        startTimeLabel.setText(startTime)
        endTimeLabel.setText(endTime)
    }

    func setProgress(_ progress: CGFloat) {
        layoutIfNeeded()
        let trackWidth = trackView.bounds.width
        guard trackWidth > 0 else { return }

        let fillWidth = trackWidth * progress
        fillWidthConstraint?.update(offset: fillWidth)

        UIView.animate(withDuration: 0.3, delay: .zero, options: .curveEaseOut) {
            self.trackView.layoutIfNeeded()
        }
    }
}
