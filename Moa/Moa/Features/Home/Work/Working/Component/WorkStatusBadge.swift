//
//  WorkStatusBadge.swift
//  Moa
//

import UIKit
import SnapKit

// MARK: - StatusBadgeView

final class StatusBadgeView: UIView {

    private let label: StyledLabel = {
        let label = StyledLabel()
        label.setStyle(.init(
            typography: AppTypography.b2_500,
            color: AppColor.IconAndText.green
        ))
        
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentHuggingPriority(.required, for: .horizontal)
        
        return label
    }()

    private var badgeType: WorkBadgeType

    init(type: WorkBadgeType) {
        self.badgeType = type
        super.init(frame: .zero)
        setupUI()
        configure(type: type)
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        layer.cornerRadius = 8
        layer.borderWidth  = 1
        clipsToBounds      = true

        setContentCompressionResistancePriority(.required, for: .vertical)
        setContentCompressionResistancePriority(.required, for: .horizontal)
        setContentHuggingPriority(.required, for: .vertical)
        setContentHuggingPriority(.required, for: .horizontal)

        addSubview(label)
        label.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(4)
            $0.leading.trailing.equalToSuperview().inset(10)
        }
    }

    func configure(type: WorkBadgeType) {
        self.badgeType = type
        label.setText(type.text, style: .init(
            typography: AppTypography.b2_500,
            color: type.indicateColor
        ))
        layer.borderColor = type.indicateColor.cgColor
    }

    func updateType(_ type: WorkBadgeType) {
        configure(type: type)
    }
}
