//
//  KeyValueRowView.swift
//  Moa
//
//  Created by 정도현 on 2/2/26.
//

import UIKit
import SnapKit

/// title + value + chevron Icon (Optional)
final class KeyValueRowView: UIView {

    // MARK: - UI

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppColor.IconAndText.mediumEmphasis
        label.font = AppTypography.b1_400.font()
        return label
    }()

    private lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppColor.IconAndText.highEmphasis
        label.font = AppTypography.b1_600.font()
        return label
    }()

    private lazy var chevronImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .Icon.iconArrowRight2)
        imageView.tintColor = AppColor.IconAndText.highEmphasis
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()

    // MARK: - Init

    init(title: String, value: String, showsChevron: Bool = false) {
        super.init(frame: .zero)
        setupUI()
        configure(title: title, value: value, showsChevron: showsChevron)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Setup

    private func setupUI() {
        addSubview(titleLabel)
        addSubview(valueLabel)
        addSubview(chevronImageView)

        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
        }

        valueLabel.snp.makeConstraints {
            $0.leading.equalTo(titleLabel.snp.trailing).offset(12)
            $0.centerY.equalToSuperview()
        }

        chevronImageView.snp.makeConstraints {
            $0.trailing.top.bottom.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.size.equalTo(18)
        }
    }

    // MARK: - Configure

    private func configure(title: String, value: String, showsChevron: Bool) {
        titleLabel.text = title
        valueLabel.text = value
        chevronImageView.isHidden = !showsChevron
    }

    // MARK: - Public API

    func updateValue(_ value: String) {
        valueLabel.text = value
    }
}
