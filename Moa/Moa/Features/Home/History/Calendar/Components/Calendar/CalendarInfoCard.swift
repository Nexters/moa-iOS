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

    private let divider: UIView = {
        let view = UIView()
        view.backgroundColor = AppColor.Divider.secondary
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

        addSubViews([workHoursTitleLabel, workHoursValueView, divider, salaryTitleLabel, salaryValueView])

        // ── 상단 섹션
        workHoursTitleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview().multipliedBy(0.5)
        }
        workHoursValueView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.centerY.equalTo(workHoursTitleLabel)
        }

        // ── 구분선
        divider.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(1)
            $0.centerY.equalToSuperview()
        }

        // ── 하단 섹션
        salaryTitleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview().multipliedBy(1.5)
        }
        salaryValueView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.centerY.equalTo(salaryTitleLabel)
        }
    }

    // MARK: - Update

    func update(with info: EarningsEntity) {
        workHoursValueView.configure(
            current: Int(Double(info.workedMinutes) / 60),
            total: Int(Double(info.standardMinutes) / 60),
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

    private static func makeTitleLabel(_ text: String) -> StyledLabel {
        let label = StyledLabel()
        label.setText(text, style: .init(
            typography: AppTypography.b2_400,
            color: AppColor.IconAndText.mediumEmphasis
        ))
        return label
    }
}


final class SlashValueView: UIView {

    // MARK: - Subviews

    private let currentLabel  = SlashValueView.makeLabel()
    private let totalLabel    = SlashValueView.makeLabel()

    private let stack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis      = .horizontal
        stackView.spacing   = 6
        return stackView
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        stack.addArrangedSubview(currentLabel)
        stack.addArrangedSubview(totalLabel)
        
        addSubview(stack)
        
        stack.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Configure
    
    func configure(current: Int, total: Int, unit: String) {
        currentLabel.setText(current.description, style: .init(
            typography: AppTypography.b1_600,
            color: AppColor.IconAndText.green
        ))
        totalLabel.setText("/ \(total)\(unit)", style: .init(
            typography: AppTypography.b1_400,
            color: AppColor.IconAndText.mediumEmphasis
        ))
    }

    // MARK: - Factory

    private static func makeLabel() -> StyledLabel {
        let label = StyledLabel()
        label.textAlignment = .right
        return label
    }
}
