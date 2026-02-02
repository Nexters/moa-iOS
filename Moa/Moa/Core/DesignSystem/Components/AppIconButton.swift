//
//  AppIconButton.swift
//  Moa
//
//  Created by 정도현 on 2/1/26.
//

import UIKit
import SnapKit

/// Moa App 내부에서 사용되는 앱 아이콘 버튼입니다.
final class AppIconButton: UIButton {

    init(
        image: UIImage?,
        iconSize: CGFloat = 24,
        buttonSize: CGFloat = 44
    ) {
        super.init(frame: .zero)
        setup(image: image, iconSize: iconSize, buttonSize: buttonSize)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Setup

    private func setup(
        image: UIImage?,
        iconSize: CGFloat,
        buttonSize: CGFloat
    ) {
        var config = UIButton.Configuration.plain()

        config.image = image
        config.preferredSymbolConfigurationForImage =
            UIImage.SymbolConfiguration(pointSize: iconSize)

        let padding = (buttonSize - iconSize) / 2
        config.contentInsets = NSDirectionalEdgeInsets(
            top: padding,
            leading: padding,
            bottom: padding,
            trailing: padding
        )

        self.configuration = config
        self.tintColor = AppColor.IconAndText.highEmphasis

        self.snp.makeConstraints {
            $0.size.equalTo(buttonSize)
        }
    }
}
