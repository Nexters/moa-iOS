//
//  SystemNotificationBannerView.swift
//  Moa
//
//  Created by mirim on 2/23/26.
//

import UIKit
import SnapKit

final class SystemNotificationBannerView: UIView {
    
    // MARK: - Properties
    
    var onSettingButtonTapped: (() -> Void)?
    
    // MARK: - UI Components
    
    private let descriptionLabel: StyledLabel = {
        let label = StyledLabel()
        label.setText(
            "OS 설정에서 알림을 켜주세요.\n출퇴근 시간에 푸시 알림을 보내드릴게요.",
            style: .init(typography: AppTypography.b2_400, color: AppColor.IconAndText.errorLight)
        )
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    private let spacerView: UIView = {
        let view = UIView()
        view.setContentHuggingPriority(.defaultLow, for: .horizontal)
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return view
    }()
    
    private let settingButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(resource: .Icon.iconChevronRight)
        return UIButton(configuration: config)
    }()
    
    private let labelButtonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        return stack
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor = AppColor.IconAndText.error.withAlphaComponent(0.12)
        layer.cornerRadius = 12
        
        labelButtonStack.addArrangedSubViews([descriptionLabel, spacerView, settingButton])
        addSubview(labelButtonStack)
        
        labelButtonStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
        
        settingButton.contentHorizontalAlignment = .leading
        settingButton.configuration?.contentInsets = .zero
        settingButton.addTarget(self, action: #selector(settingTapped), for: .touchUpInside)
    }
    
    @objc private func settingTapped() {
        onSettingButtonTapped?()
    }
}
