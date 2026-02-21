//
//  SettingSectionView.swift
//  Moa
//
//  Created by mirim on 2/21/26.
//

import UIKit
import SnapKit

final class SettingSectionView: UIView {
    private let titleLabel: StyledLabel = {
        let label = StyledLabel()
        label.setStyle(.init(
            typography: AppTypography.b2_500,
            color: AppColor.IconAndText.mediumEmphasis
        ))
        return label
    }()

    private let rowsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
    }()

    init(title: String, rows: [UIView]) {
        super.init(frame: .zero)
        titleLabel.setText(title)
        setupUI(rows: rows)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI(rows: [UIView]) {
        addSubViews([titleLabel, rowsStack])

        titleLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }

        rows.forEach { rowsStack.addArrangedSubview($0) }

        rowsStack.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}
