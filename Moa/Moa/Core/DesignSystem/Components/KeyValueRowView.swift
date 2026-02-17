//
//  KeyValueRowView.swift
//  Moa
//
//  Created by 정도현 on 2/2/26.
//

import UIKit
import SnapKit

enum KeyValueRowType {
    case wageRow(wage: Int)
    case timeRow(startTime: String, endTime: String)
    
    var title: String {
        switch self {
        case .wageRow:
            return "오늘 일급"
        case .timeRow:
            return "근무 시간"
        }
    }
    
    var value: String {
        switch self {
        case let .wageRow(wage):
            return "\(AppNumberFormatter.decimalString(from: wage))원"
        case let .timeRow(startTime, endTime):
            return "\(startTime) - \(endTime)"
        }
    }
}

/// title + value + optional chevron
final class KeyValueRowView: UIControl {
    
    // MARK: - UI
    private lazy var titleLabel: StyledLabel = {
        let label = StyledLabel()
        label.setStyle(
            .init(
                typography: AppTypography.b1_400,
                color: AppColor.IconAndText.mediumEmphasis
            )
        )
        return label
    }()

    private lazy var valueLabel: StyledLabel = {
        let label = StyledLabel()
        label.setStyle(
            .init(
                typography: AppTypography.b1_600,
                color: AppColor.IconAndText.highEmphasis
            )
        )
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()

    private lazy var chevronImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(resource: .Icon.iconChevronRight)
            .withRenderingMode(.alwaysTemplate)
        imageView.tintColor = AppColor.IconAndText.lowEmphasis
        imageView.isHidden = !showsChevron
        return imageView
    }()

    
    // MARK: - Properties
    
    private let showsChevron: Bool
    
    /// 외부 액션
    var onTap: (() -> Void)? {
        didSet {
            isUserInteractionEnabled = onTap != nil
        }
    }
    
    // MARK: - Init
    
    init(type: KeyValueRowType, showsChevron: Bool = false) {
        self.showsChevron = showsChevron
        super.init(frame: .zero)
        
        setupUI()
        configure(with: type)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        
        clipsToBounds = true
        backgroundColor = .clear
        
        addTarget(self, action: #selector(didTapRow), for: .touchUpInside)
                
        addSubViews(
            [
                titleLabel,
                valueLabel,
                chevronImageView
            ]
        )
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        
        chevronImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.size.equalTo(24)
        }
        
        valueLabel.snp.makeConstraints {
            $0.leading.equalTo(titleLabel.snp.trailing).offset(12)
            $0.centerY.equalToSuperview()
            $0.trailing.lessThanOrEqualTo(
                showsChevron
                ? chevronImageView.snp.leading
                : snp.trailing
            ).offset(showsChevron ? -8 : 0)
        }
        
        isAccessibilityElement = true
        accessibilityTraits = .button
    }
    
    // MARK: - Configure
    
    private func configure(with type: KeyValueRowType) {
        titleLabel.setText(type.title)
        valueLabel.setText(type.value)
        updateAccessibility()
    }
    
    func updateValue(_ value: String) {
        valueLabel.setText(value)
        updateAccessibility()
    }
    
    private func updateAccessibility() {
        accessibilityLabel = "\(titleLabel.text ?? ""), \(valueLabel.text ?? "")"
    }
    
    // MARK: - Action
    
    @objc
    private func didTapRow() {
        onTap?()
    }
    
    // MARK: - Intrinsic Size
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: 24)
    }
}
