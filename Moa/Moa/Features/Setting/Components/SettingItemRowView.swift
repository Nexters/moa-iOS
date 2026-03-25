//
//  SettingItemRowView.swift
//  Moa
//
//  Created by mirim on 2/21/26.
//

import UIKit
import SnapKit

final class SettingItemRowView: UIView {
    
    // MARK: - Constants
    
    private enum Constants {
        static let unregistered = "미등록"
    }
    
    // 탭 액션 콜백
    var onTap: (() -> Void)?
    
    // MARK: - UI Components
    
    private let spacerView: UIView = {
        let v = UIView()
        v.setContentHuggingPriority(.defaultLow, for: .horizontal)
        v.setContentCompressionResistancePriority(UILayoutPriority(1), for: .horizontal)
        return v
    }()
    
    private lazy var horizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.addArrangedSubViews([titleSubtitleStack, spacerView, valueLabel, trailingImageView, chevronImage])
        stackView.setCustomSpacing(4, after: valueLabel)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        stackView.backgroundColor = AppColor.Container.primary
        stackView.layer.cornerRadius = 12
        stackView.alignment = .center
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
        stack.axis = .horizontal
        stack.spacing = 6
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
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    private let chevronImage: UIImageView = {
        let imgView = UIImageView()
        imgView.image = .init(resource: .Icon.iconChevronRight).withRenderingMode(.alwaysTemplate)
        imgView.tintColor = AppColor.IconAndText.lowEmphasis
        return imgView
    }()
    
    private lazy var trailingImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
        imgView.isHidden = true
        imgView.tintColor = AppColor.IconAndText.highEmphasis
        return imgView
    }()
    
    // MARK: - Public Update APIs
    func updateValue(_ newValue: String?) {
        if let newValue, !newValue.isEmpty {
            let isUnregistered = newValue == Constants.unregistered
            
            valueLabel.setText(
                newValue,
                style: .init(
                    typography: AppTypography.b1_500,
                    color: isUnregistered ? AppColor.IconAndText.disabled : AppColor.IconAndText.green
                )
            )
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
    
    func setChevronVisible(_ visible: Bool) {
        chevronImage.isHidden = !visible
    }
    
    init(title: String, subtitle: String? = nil, value: String? = nil, showsChevron: Bool = true, trailingImage: UIImage? = nil) {
        super.init(frame: .zero)
        
        titleLabel.setText(title)
        updateValue(value)
        updateSubtitle(subtitle)
        chevronImage.isHidden = !showsChevron
        
        if let trailingImage {
            trailingImageView.image = trailingImage
            trailingImageView.isHidden = false
        }
        
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
        
        spacerView.snp.makeConstraints {
            $0.width.greaterThanOrEqualTo(16)
        }
        
        chevronImage.snp.makeConstraints {
            $0.width.height.equalTo(24)
        }
        
        trailingImageView.snp.makeConstraints {
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
