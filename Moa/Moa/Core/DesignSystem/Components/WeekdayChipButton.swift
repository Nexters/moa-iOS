//
//  WeekdayChipButton.swift
//  Moa
//
//  Created by mirim on 2/4/26.
//

import UIKit
import SnapKit

final class WeekdayChipButton: BaseChipButton {
    
    private enum Constant {
        static let minHeight: CGFloat = 44
        static let inset: CGFloat = 10
        static let cornerRadius: CGFloat = 8
    }
    
    init(title: String) {
        super.init(
            title: title,
            style: .init(
                cornerRadius: Constant.cornerRadius,
                contentInsets: .init(top: Constant.inset, leading: Constant.inset, bottom: Constant.inset, trailing: Constant.inset),
                fontNormal: AppTypography.b1_500.font(),
                fontSelected: AppTypography.b1_600.font(),
                bgNormal: AppColor.Container.primary,
                bgSelected: AppColor.IconAndText.highEmphasis,
                fgNormal: AppColor.IconAndText.disabled,
                fgSelected: AppColor.IconAndText.highEmphasisReverse
            )
        )
        
        snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(Constant.minHeight)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
