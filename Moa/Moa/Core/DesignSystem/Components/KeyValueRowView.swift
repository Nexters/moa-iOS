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
        let label = StyledLabel()
        label.textStyle = .init(
            typography: AppTypography.b1_400,
            color: AppColor.IconAndText.mediumEmphasis
        )
        return label
    }()
    
    private lazy var valueLabel: UILabel = {
        let label = StyledLabel()
        label.textStyle = .init(
            typography: AppTypography.b1_600,
            color: AppColor.IconAndText.highEmphasis
        )
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()
    
    private lazy var chevronImageBtn: AppIconButton = {
        let iconBtn = AppIconButton(
            image: .Icon.iconChevronRight,
            iconSize: 18,
            buttonSize: 24,
            tintColor: AppColor.IconAndText.lowEmphasis
        )
        
        iconBtn.isHidden = true
        return iconBtn
    }()
    
    // MARK: - Init
    
    init(title: String, value: String, showsChevron: Bool = false) {
        super.init(frame: .zero)
        
        setupUI()
        configure(title: title, value: value, showsChevron: showsChevron)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        addSubview(titleLabel)
        addSubview(valueLabel)
        addSubview(chevronImageBtn)
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalToSuperview().inset(0)
            $0.bottom.equalToSuperview().inset(0)
        }
        
        valueLabel.snp.makeConstraints {
            $0.leading.equalTo(titleLabel.snp.trailing).offset(12)
            $0.centerY.equalTo(titleLabel)
            $0.trailing.lessThanOrEqualTo(chevronImageBtn.snp.leading)
                .offset(-8)
                .priority(.high)
        }
        
        chevronImageBtn.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalTo(titleLabel)
        }
    }
    
    // MARK: - Configure
    
    private func configure(title: String, value: String, showsChevron: Bool) {
        titleLabel.text = title
        valueLabel.text = value
        chevronImageBtn.isHidden = !showsChevron
    }
    
    // MARK: - Public API
    
    func updateValue(_ value: String) {
        valueLabel.text = value
    }
}
