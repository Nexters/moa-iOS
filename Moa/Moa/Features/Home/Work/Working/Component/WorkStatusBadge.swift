//
//  WorkStatusBadge.swift
//  Moa
//

import UIKit
import SnapKit

// MARK: - BadgeType

enum BadgeType {
    case working
    case lunch
    case vacation
    case overtime

    var text: String {
        switch self {
        case .working:  return "근무 중"
        case .lunch:    return "점심시간"
        case .vacation: return "휴가"
        case .overtime: return "추가 근무"
        }
    }

    var indicateColor: UIColor {
        switch self {
        case .working:  return AppColor.IconAndText.green
        case .lunch:    return AppColor.IconAndText.blue
        case .vacation: return AppColor.IconAndText.blue
        case .overtime: return AppColor.IconAndText.error
        }
    }
}

// MARK: - StatusBadgeView

final class StatusBadgeView: UIView {

    private let label: StyledLabel = {
        let label = StyledLabel()
        label.setStyle(.init(
            typography: AppTypography.b2_500,
            color: AppColor.IconAndText.green
        ))
        // 텍스트가 어떤 상황에서도 압축되지 않도록
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()

    private var badgeType: BadgeType

    init(type: BadgeType) {
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

        // 뷰 자체도 압축 방지
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

    func configure(type: BadgeType) {
        self.badgeType = type
        label.setText(type.text, style: .init(
            typography: AppTypography.b2_500,
            color: type.indicateColor
        ))
        layer.borderColor = type.indicateColor.cgColor
    }

    func updateType(_ type: BadgeType) {
        configure(type: type)
    }
}
