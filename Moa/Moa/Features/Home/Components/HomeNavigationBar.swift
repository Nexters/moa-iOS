//
//  HomeNavigationBar.swift
//  Moa
//
//  Created by 정도현 on 2/1/26.
//

import UIKit
import SnapKit

final class HomeNavigationBarView: UIView {

    private let titleLabel = UILabel()
    private let calendarButton = AppIconButton()
    private let settingButton = AppIconButton()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        titleLabel.text = "Moa"
        titleLabel.textColor = .white
        titleLabel.font = AppTypography.t3_500.font()

        calendarButton.setImage(UIImage(systemName: "calendar"), for: .normal)
        settingButton.setImage(UIImage(systemName: "gearshape"), for: .normal)

        calendarButton.tintColor = .white
        settingButton.tintColor = .white
    }

    private func setupLayout() {
        let rightStack = UIStackView(arrangedSubviews: [
            calendarButton,
            settingButton
        ])
        rightStack.axis = .horizontal
        rightStack.spacing = 16
        rightStack.alignment = .center

        let container = UIStackView(arrangedSubviews: [
            titleLabel,
            UIView(),
            rightStack
        ])
        container.axis = .horizontal
        container.alignment = .center

        addSubview(container)

        container.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(20)
        }

        [calendarButton, settingButton].forEach {
            $0.snp.makeConstraints {
                $0.width.height.equalTo(32)
            }
        }
    }
}
