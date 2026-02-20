//
//  CalendarDayCell.swift
//  Moa
//
//  Created by 정도현 on 2/19/26.
//

import UIKit
import SnapKit

protocol CalendarDayCellDelegate: AnyObject {
    func dayCell(_ cell: CalendarDayCell, didTap day: CalendarDay)
}

final class CalendarDayCell: UICollectionViewCell {
    
    static let identifier = "CalendarDayCell"
    weak var delegate: CalendarDayCellDelegate?
    
    private var tappedDay: CalendarDay?
    
    // MARK: - UI
    
    private let dateContainer = UIView()
    
    private let selectionCircle: UIView = {
        let v = UIView()
        v.backgroundColor = AppColor.Container.secondary
        v.layer.cornerRadius = 14
        v.isHidden = true
        return v
    }()
    
    private let dateLabel: StyledLabel = {
        let l = StyledLabel()
        l.textAlignment = .center
        return l
    }()
    
    private let indicator = CalendarDayIndicatorView()
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
        
        selectionCircle.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
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
    
    func configure(with day: CalendarDay?) {
        
        reset()
        guard let day else { return }
        
        tappedDay = day
        let number = Calendar.current.component(.day, from: day.date)
        
        var textColor = day.isCurrentMonth
        ? AppColor.IconAndText.highEmphasis
        : AppColor.IconAndText.disabled
        
        var font = AppTypography.b1_400
        
        if day.isSelected {
            selectionCircle.isHidden = false
            font = AppTypography.b1_600
        }
        
        if day.isToday {
            textColor = AppColor.IconAndText.green
            font = AppTypography.b1_600
        }
        
        dateLabel.setText(
            "\(number)",
            style: .init(
                typography: font,
                color: textColor
            )
        )
        
        switch day.contentType {
        case .scheduled, .worked:
            setIndicatorHeight(14)
        case .dualLabel, .singleLabel:
            setIndicatorHeight(18)
        case .none:
            setIndicatorHeight(0)
        }
        
        indicator.configure(type: day.contentType)
    }
    
    // MARK: - Helpers
    
    private func reset() {
        tappedDay = nil
        selectionCircle.isHidden = true
        dateLabel.text = nil
        dateLabel.attributedText = nil
        indicator.configure(type: .none)
        setIndicatorHeight(0)
    }
    
    private func setIndicatorHeight(_ height: CGFloat) {
        indicatorHeightConstraint?.update(offset: height)
    }
    
    @objc private func handleTap() {
        guard let day = tappedDay else { return }
        delegate?.dayCell(self, didTap: day)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }
}
