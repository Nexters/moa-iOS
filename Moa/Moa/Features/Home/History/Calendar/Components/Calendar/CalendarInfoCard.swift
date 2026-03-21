//
//  CalendarInfoCard.swift
//  Moa
//
//  Created by 정도현 on 2/19/26.
//

import UIKit
import SnapKit

// MARK: - CalendarInfoCard

final class CalendarInfoCard: UIView {

    // MARK: - Subviews

    /// 근무시간 레이블 + 값
    private let workHoursTitleLabel = CalendarInfoCard.makeTitleLabel("근무시간")
    private let workHoursValueView  = SlashValueView()

    /// 내 월급 레이블 + 값
    private let salaryTitleLabel    = CalendarInfoCard.makeTitleLabel("내 월급")
    private let salaryValueView     = SlashValueView()

    private lazy var workRow = makeRow(
        titleLabel: workHoursTitleLabel,
        valueView: workHoursValueView
    )

    private lazy var salaryRow = makeRow(
        titleLabel: salaryTitleLabel,
        valueView: salaryValueView
    )

    private lazy var containerStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            workRow,
            divider,
            salaryRow
        ])
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }()
    
    private let divider: UIView = {
        let view = UIView()
        view.backgroundColor = .white.withAlphaComponent(0.12)
        return view
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Setup

    private func setup() {
        backgroundColor    = AppColor.Container.secondary
        layer.cornerRadius = 16
        clipsToBounds      = true

        addSubview(containerStack)

        divider.snp.makeConstraints {
            $0.height.equalTo(1)
        }
        
        containerStack.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(12)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
    }
       
    // MARK: - Update

    func update(with info: EarningsEntity) {
        workHoursValueView.configure(
            current: Int(round(Double(info.workedMinutes) / 60)),
            total: Int(round(Double(info.standardMinutes) / 60)),
            unit: "시간"
        )
        
        let currentManWon = info.workedEarnings / 10_000
        let totalManWon   = info.standardSalary / 10_000

        salaryValueView.configure(
            current: currentManWon,
            total: totalManWon,
            unit: "만원"
        )
    }

    // MARK: - Factory

    private static func makeTitleLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = AppTypography.b2_400.font()
        label.textColor = AppColor.IconAndText.mediumEmphasis
        label.textAlignment = .center
        return label
    }
    
    private func makeRow(
        titleLabel: UILabel,
        valueView: UIView
    ) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: [titleLabel, valueView])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .equalSpacing
        return stack
    }
}
