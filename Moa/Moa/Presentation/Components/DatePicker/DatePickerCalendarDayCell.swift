//
//  DatePickerCalendarDayCell.swift
//  Moa
//
//  Created by 정도현 on 2/20/26.
//

import UIKit
import SnapKit

protocol DatePickerCalendarDayCellDelegate: AnyObject {
    func datePickerDayCell(_ cell: DatePickerCalendarDayCell, didTap day: CalendarDayEntity)
}

/// 바텀시트용 날짜 선택 셀
final class DatePickerCalendarDayCell: UICollectionViewCell {

    static let identifier = "DatePickerCalendarDayCell"
    weak var delegate: DatePickerCalendarDayCellDelegate?

    private var tappedDay: CalendarDayEntity?

    // MARK: - UI

    private let selectionCircle: UIView = {
        let v = UIView()
        v.backgroundColor = AppColor.IconAndText.green
        v.layer.cornerRadius = 14
        v.isHidden = true
        return v
    }()

    private let dateLabel: StyledLabel = {
        let l = StyledLabel()
        l.textAlignment = .center
        return l
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubViews([selectionCircle, dateLabel])

        selectionCircle.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(28)
        }

        dateLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(1)
        }

        contentView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(handleTap))
        )
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Configure

    func configure(with day: CalendarDayEntity?) {
        reset()
        guard let day else { return }

        tappedDay = day
        let number = Calendar.current.component(.day, from: day.date)

        let textColor: UIColor
        let font: TypographyStyle

        if day.isSelected {
            selectionCircle.isHidden = false
            textColor = AppColor.Background.primary
            font = AppTypography.b1_600
        } else if day.isCurrentMonth {
            textColor = AppColor.IconAndText.highEmphasis
            font = AppTypography.b1_400
        } else {
            textColor = AppColor.IconAndText.disabled
            font = AppTypography.b1_400
        }

        dateLabel.setText(
            "\(number)",
            style: .init(typography: font, color: textColor)
        )
    }

    // MARK: - Helpers

    private func reset() {
        tappedDay = nil
        selectionCircle.isHidden = true
        dateLabel.text = nil
        dateLabel.attributedText = nil
    }

    @objc private func handleTap() {
        guard let day = tappedDay else { return }
        delegate?.datePickerDayCell(self, didTap: day)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }
}
