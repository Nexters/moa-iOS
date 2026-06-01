//
//  CalendarDayCell.swift
//  Moa
//

import UIKit
import SnapKit

protocol CalendarDayCellDelegate: AnyObject {
    func dayCell(_ cell: CalendarDayCell, didTap schedule: CalendarScheduleEntity)
}

final class CalendarDayCell: UICollectionViewCell {

    static let identifier = "CalendarDayCell"
    weak var delegate: CalendarDayCellDelegate?

    private var tappedSchedule: CalendarScheduleEntity?

    // MARK: - UI

    private let dateContainer = UIView()

    private let selectionCircle: UIView = {
        let view = UIView()
        view.backgroundColor   = AppColor.Container.secondary
        view.layer.cornerRadius = 14
        view.isHidden           = true
        return view
    }()

    private let dateLabel: StyledLabel = {
        let label           = StyledLabel()
        label.textAlignment = .center
        return label
    }()

    private let indicator          = CalendarDayIndicatorView()
    private var indicatorHeightConstraint: Constraint?

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubViews([dateContainer, indicator])
        dateContainer.addSubViews([selectionCircle, dateLabel])

        dateContainer.snp.makeConstraints {
            $0.top.equalToSuperview().offset(2)
            $0.width.height.equalTo(28)
            $0.centerX.equalToSuperview()
        }
        selectionCircle.snp.makeConstraints { $0.edges.equalToSuperview() }
        dateLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(1)
        }
        indicator.snp.makeConstraints {
            $0.top.equalTo(dateContainer.snp.bottom).offset(6)
            $0.centerX.equalToSuperview()
            indicatorHeightConstraint = $0.height.equalTo(0).constraint
        }

        contentView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(handleTap))
        )
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Configure

    func configure(
        with schedule: CalendarScheduleEntity?,
        calendarType: CalendarNavigationType = .history
    ) {
        reset()
        guard let schedule else { return }

        tappedSchedule = schedule
        let number     = Calendar.current.component(.day, from: schedule.date)

        var textColor: UIColor = schedule.isCurrentMonth
            ? AppColor.IconAndText.highEmphasis
            : AppColor.IconAndText.disabled
        var font = AppTypography.b1_400

        if schedule.isSelected {
            selectionCircle.isHidden = false
            font = AppTypography.b1_600

            switch calendarType {
            case .bottomSheet:
                selectionCircle.backgroundColor = AppColor.IconAndText.green
                textColor = AppColor.IconAndText.highEmphasisReverse
            case .history:
                selectionCircle.backgroundColor = AppColor.Container.secondary
                textColor = AppColor.IconAndText.highEmphasis
            }
        }

        if schedule.isToday && !schedule.isSelected {
            switch calendarType {
            case .history:
                textColor = AppColor.IconAndText.green
                font      = AppTypography.b1_500
            case .bottomSheet:
                break
            }
        }

        dateLabel.setText(
            "\(number)",
            style: .init(typography: font, color: textColor)
        )

        // 인디케이터 높이 결정
        //   월급/휴가 레이블이 있으면 18pt, 근무 점이면 14pt, 없으면 0
        let hasLabel = schedule.events.contains(.payday) || schedule.events.contains(.publicHoliday) || schedule.contentType == .vacation
        let hasDot   = schedule.contentType == .work && schedule.status != .none
        if hasLabel {
            setIndicatorHeight(18)
        } else if hasDot {
            setIndicatorHeight(14)
        } else {
            setIndicatorHeight(0)
        }

        indicator.configure(schedule: schedule)
    }

    // MARK: - Helpers

    private func reset() {
        tappedSchedule                  = nil
        selectionCircle.isHidden        = true
        selectionCircle.backgroundColor = AppColor.Container.secondary
        dateLabel.text                  = nil
        dateLabel.attributedText        = nil
        indicator.configure(schedule: nil)
        setIndicatorHeight(0)
    }

    private func setIndicatorHeight(_ height: CGFloat) {
        indicatorHeightConstraint?.update(offset: height)
    }

    @objc private func handleTap() {
        guard let schedule = tappedSchedule else { return }
        delegate?.dayCell(self, didTap: schedule)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }
}
