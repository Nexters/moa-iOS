//
//  OptionChipButton.swift
//  Moa
//
//  Created by mirim on 2/4/26.
//

import UIKit

final class OptionChipButton: BaseChipButton {
    init(title: String) {
        super.init(
            title: title,
            style: .init(
                cornerRadius: 12.0,
                contentInsets: .init(top: 16.0, leading: 20.0, bottom: 16.0, trailing: 20.0),
                fontNormal: AppTypography.t2_500.font(),
                fontSelected: AppTypography.t2_700.font(),
                bgNormal: AppColor.Background.primary,
                bgSelected: AppColor.Background.primary,
                fgNormal: AppColor.IconAndText.disabled,
                fgSelected: AppColor.IconAndText.highEmphasis
            )
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
