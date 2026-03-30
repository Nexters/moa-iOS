//
//  CalendarDayIndicatorView.swift
//  Moa
//

import UIKit
import SnapKit

final class CalendarDayIndicatorView: UIView {

    private let dotView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 3
        view.isHidden           = true
        return view
    }()

    private let labelStack: UIStackView = {
        let sv       = UIStackView()
        sv.axis      = .horizontal
        sv.spacing   = 2
        sv.alignment = .center
        sv.isHidden  = true
        return sv
    }()

    private let primaryLabel   = CalendarDayIndicatorView.makeLabel()
    private let separatorLabel = CalendarDayIndicatorView.makeLabel()
    private let secondaryLabel = CalendarDayIndicatorView.makeLabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        labelStack.addArrangedSubview(primaryLabel)
        labelStack.addArrangedSubview(separatorLabel)
        labelStack.addArrangedSubview(secondaryLabel)

        addSubViews([dotView, labelStack])

        dotView.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 6, height: 6))
            $0.center.equalToSuperview()
        }
        labelStack.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.lessThanOrEqualToSuperview()
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Configure
    //
    // CalendarScheduleEntity를 직접 받아서 인디케이터 결정
    //
    // 우선순위:
    //   1. events에 .payday 포함 + contentType == .vacation → 월급 · 휴가
    //   2. events에 .payday 포함                            → 월급
    //   3. contentType == .vacation                         → 휴가
    //   4. contentType == .work + status == .completed      → 초록 점
    //   5. contentType == .work + status == .scheduled      → 회색 점
    //   6. 그 외                                            → 없음

    func configure(schedule: CalendarScheduleEntity?) {
        reset()
        guard let schedule else { return }

        let hasPayday  = schedule.events.contains(.payday)
        let isVacation = schedule.contentType == .vacation
        let isWork     = schedule.contentType == .work

        if hasPayday && isVacation {
            showDualLabel(primary: "월급", secondary: "휴가")
        } else if hasPayday {
            showSingleLabel("월급", color: AppColor.IconAndText.green)
        } else if isVacation {
            showSingleLabel("휴가", color: AppColor.IconAndText.mediumEmphasis)
        } else if isWork {
            switch schedule.status {
            case .completed:
                showDot(color: AppColor.IconAndText.green)
            case .scheduled:
                showDot(color: AppColor.Container.secondary)
            case .none:
                break
            }
        }
    }

    // MARK: - Private Helpers

    private func reset() {
        dotView.isHidden            = true
        dotView.backgroundColor     = .clear
        labelStack.isHidden         = true
        primaryLabel.isHidden       = false
        separatorLabel.isHidden     = true
        secondaryLabel.isHidden     = true
        primaryLabel.text           = nil
        separatorLabel.text         = nil
        secondaryLabel.text         = nil
    }

    private func showDot(color: UIColor) {
        dotView.isHidden        = false
        dotView.backgroundColor = color
    }

    private func showSingleLabel(_ text: String, color: UIColor) {
        labelStack.isHidden = false
        primaryLabel.setText(
            text,
            style: .init(typography: AppTypography.c1_400, color: color)
        )
    }

    private func showDualLabel(primary: String, secondary: String) {
        labelStack.isHidden     = false
        separatorLabel.isHidden = false
        secondaryLabel.isHidden = false
        primaryLabel.setText(
            primary,
            style: .init(typography: AppTypography.c1_400, color: AppColor.IconAndText.green)
        )
        separatorLabel.setText(
            "·",
            style: .init(typography: AppTypography.c1_400, color: AppColor.IconAndText.mediumEmphasis)
        )
        secondaryLabel.setText(
            secondary,
            style: .init(typography: AppTypography.c1_400, color: AppColor.IconAndText.mediumEmphasis)
        )
    }

    private static func makeLabel() -> StyledLabel {
        let label           = StyledLabel()
        label.textAlignment = .center
        return label
    }
}
