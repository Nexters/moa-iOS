//
//  NotificationToggleItemView.swift
//  Moa
//
//  Created by mirim on 2/23/26.
//

import UIKit
import SnapKit

final class NotificationToggleItemView: UIView {
    
    // MARK: - Properties
    
    var onToggleChanged: ((Bool) -> Void)?
    
    var isEnabled: Bool = true {
        didSet { updateEnabledState() }
    }
    
    var isOn: Bool {
        get { toggle.isOn }
        set { toggle.setOn(newValue, animated: false) }
    }
    
    // MARK: - UI Components
    
    private let titleLabel: StyledLabel = {
        let label = StyledLabel()
        label.setStyle(.init(typography: AppTypography.b1_500, color: AppColor.IconAndText.highEmphasis))
        return label
    }()
    
    private let toggle: UISwitch = {
        let sw = UISwitch()
        sw.onTintColor = AppColor.IconAndText.green
        return sw
    }()
    
    // MARK: - Init
    
    init(title: String) {
        super.init(frame: .zero)
        titleLabel.setText(title)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor = AppColor.Container.primary
        layer.cornerRadius = 12
        
        addSubview(titleLabel)
        addSubview(toggle)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualTo(toggle.snp.leading).offset(-8)
        }
        
        toggle.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
        
        snp.makeConstraints { make in
            make.height.equalTo(56)
        }
        
        toggle.addTarget(self, action: #selector(toggleChanged), for: .valueChanged)
    }
    
    private func updateEnabledState() {
        toggle.isEnabled = isEnabled
        let textColor = isEnabled ? AppColor.IconAndText.highEmphasis : AppColor.IconAndText.disabled
        
        titleLabel.setStyle(.init(
            typography: AppTypography.b1_500,
            color: textColor
        ))
    }
    
    @objc private func toggleChanged(_ sender: UISwitch) {
        onToggleChanged?(sender.isOn)
    }
}
