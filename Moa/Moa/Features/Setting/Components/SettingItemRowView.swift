//
//  SettingItemRowView.swift
//  Moa
//
//  Created by mirim on 2/21/26.
//

import UIKit
import SnapKit

final class SettingItemRowView: UIView {
    
    // 탭 액션 콜백
    var onTap: (() -> Void)?
    
    // MARK: - UI Components
    
    private let spacerView: UIView = {
        let v = UIView()
        v.setContentHuggingPriority(.defaultLow, for: .horizontal)
        v.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return v
    }()
    
    private lazy var horizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.addArrangedSubViews([titleSubtitleStack, spacerView, valueLabel, chevronImage])
        stackView.setCustomSpacing(4, after: valueLabel)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        stackView.backgroundColor = AppColor.Container.primary
        stackView.layer.cornerRadius = 12
        return stackView
    }()
    
    private lazy var titleLabel: StyledLabel = {
        let label = StyledLabel()
        label.setStyle(.init(
            typography: AppTypography.b1_500,
            color: AppColor.IconAndText.highEmphasis
        ))
        return label
    }()
    
    private lazy var subtitleLabel: StyledLabel = {
        let label = StyledLabel()
        label.setStyle(.init(
            typography: AppTypography.b1_400,
            color: AppColor.IconAndText.mediumEmphasis
        ))
        label.isHidden = true
        return label
    }()

    private lazy var titleSubtitleStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .leading
        stack.distribution = .fill
        stack.addArrangedSubViews([titleLabel, subtitleLabel])
        return stack
    }()
    
    private lazy var valueLabel: StyledLabel = {
        let label = StyledLabel()
        label.setStyle(.init(
            typography: AppTypography.b1_500,
            color: AppColor.IconAndText.green
        ))
        return label
    }()
    
    private let chevronImage: UIImageView = {
        let imgView = UIImageView()
        imgView.image = .init(resource: .Icon.iconChevronRight).withRenderingMode(.alwaysTemplate)
        imgView.tintColor = AppColor.IconAndText.lowEmphasis
        return imgView
    }()
    
    // MARK: - Public Update APIs
    func updateValue(_ newValue: String?) {
        if let newValue, !newValue.isEmpty {
            valueLabel.setText(newValue)
            valueLabel.isHidden = false
        } else {
            valueLabel.setText("")
            valueLabel.isHidden = true
        }
    }

    func updateSubtitle(_ newSubtitle: String?) {
        if let newSubtitle, !newSubtitle.isEmpty {
            subtitleLabel.setText(newSubtitle)
            subtitleLabel.isHidden = false
        } else {
            subtitleLabel.setText("")
            subtitleLabel.isHidden = true
        }
    }
    
    init(title: String, subtitle: String? = nil, value: String? = nil, showsChevron: Bool = true) {
        super.init(frame: .zero)
        
        titleLabel.setText(title)
        updateValue(value)
        updateSubtitle(subtitle)
        chevronImage.isHidden = !showsChevron
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        addSubview(horizontalStackView)
        
        horizontalStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        chevronImage.snp.makeConstraints {
            $0.width.height.equalTo(24)
        }
        
        setContentHuggingPriority(.required, for: .horizontal)
        setContentCompressionResistancePriority(.required, for: .horizontal)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTap))
        addGestureRecognizer(tap)
        isUserInteractionEnabled = true
    }
    
    @objc private func didTap() {
        onTap?()
    }
}

