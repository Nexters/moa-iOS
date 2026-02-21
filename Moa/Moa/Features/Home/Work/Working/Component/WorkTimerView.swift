//
//  WorkTimerView.swift
//  Moa
//
//  Created by 정도현 on 2/18/26.
//

import UIKit
import SnapKit

// MARK: - WorkTimerView

final class WorkTimerView: UIView {

    private let hoursLabel = makeTimeLabel()
    private let colon1Label = makeColonLabel()
    private let minutesLabel = makeTimeLabel()
    private let colon2Label = makeColonLabel()
    private let secondsLabel = makeTimeLabel()

    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            hoursLabel, colon1Label, minutesLabel, colon2Label, secondsLabel
        ])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 2
        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    func setElapsed(seconds totalSeconds: Int) {
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        hoursLabel.setText(String(format: "%d", hours))
        minutesLabel.setText(String(format: "%02d", minutes))
        secondsLabel.setText(String(format: "%02d", seconds))
    }

    private static func makeTimeLabel() -> StyledLabel {
        let label = StyledLabel()
        label.setStyle(.init(
            typography: AppTypography.h3_700,
            color: AppColor.IconAndText.highEmphasis
        ))
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }

    private static func makeColonLabel() -> StyledLabel {
        let label = StyledLabel()
        label.setText(":", style: .init(
            typography: AppTypography.h3_500,
            color: AppColor.IconAndText.mediumEmphasis
        ))
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }
}
