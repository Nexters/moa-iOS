//
//  WeekdayChipButton.swift
//  Moa
//
//  Created by mirim on 2/4/26.
//

import UIKit

final class WeekdayChipButton: BaseChipButton {
    init(title: String) {
        super.init(
            title: title,
            style: .init(
                cornerRadius: 8.0,
                contentInsets: .init(top: 10.0, leading: 10.0, bottom: 10.0, trailing: 10.0),
                fontNormal: AppTypography.b1_500.font(),
                fontSelected: AppTypography.b1_600.font(),
                bgNormal: AppColor.Container.primary,
                bgSelected: AppColor.IconAndText.highEmphasis,
                fgNormal: AppColor.IconAndText.disabled,
                fgSelected: AppColor.IconAndText.highEmphasisReverse
            )
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
