//
//  TimeWheelCell.swift
//  Moa
//
//  Created by 정도현 on 2/14/26.
//

import UIKit
import SnapKit

final class TimeWheelCell: UICollectionViewCell {
    
    static let identifier = "WheelCell"
    
    private lazy var label: StyledLabel = {
        let label = StyledLabel()
        label.setText(
            "",
            style: .init(
                typography: AppTypography.t3_500,
                color: AppColor.IconAndText.lowEmphasis
            )
        )
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(label)
        
        label.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(4)
            $0.leading.trailing.equalToSuperview().inset(45)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func configure(text: String, alignment: NSTextAlignment) {
        label.text = text
        label.textAlignment = alignment
    }
    
    func setSelectedStyle(_ isSelected: Bool) {
        label.setText(
            label.text,
            style: .init(
                typography: isSelected ? AppTypography.t2_500 : AppTypography.t3_500,
                color: isSelected
                ? AppColor.IconAndText.highEmphasis
                : AppColor.IconAndText.lowEmphasis
            )
        )
    }
}
