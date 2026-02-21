//
//  WorkProgressBar.swift
//  Moa
//
//  Created by 정도현 on 2/18/26.
//

import UIKit
import SnapKit

final class WorkProgressBar: UIView {

    // MARK: - UI

    private let trackView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColor.IconAndText.disabled
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        return view
    }()

    private let fillView: UIView = {
        let view = UIView()
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

    // MARK: - Init

    init(workingType: WorkingType) {
        super.init(frame: .zero)
        
        fillView.backgroundColor = workingType.barColor  // lazy 제거 → init에서 직접 설정
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Setup

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
            $0.leading.bottom.equalToSuperview()
        }

        endTimeLabel.snp.makeConstraints {
            $0.top.equalTo(trackView.snp.bottom).offset(4)
            $0.trailing.bottom.equalToSuperview()
        }
    }

    // MARK: - Public

    func configure(startTime: String, endTime: String) {
        startTimeLabel.setText(startTime)
        endTimeLabel.setText(endTime)
    }

    /// workingType 전환 시 바 색상 업데이트
    func updateBarColor(_ workingType: WorkingType) {
        fillView.backgroundColor = workingType.barColor
    }

    func setProgress(_ progress: CGFloat) {
        layoutIfNeeded()
        let trackWidth = trackView.bounds.width
        guard trackWidth > 0 else { return }

        let clamped = max(0, min(1, progress))
        fillWidthConstraint?.update(offset: trackWidth * clamped)

        UIView.animate(withDuration: 0.25) {
            self.trackView.layoutIfNeeded()
        }
    }
}
