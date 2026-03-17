//
//  HomeNavigationBar.swift
//  Moa
//
//  Created by 정도현 on 2/1/26.
//

import UIKit
import SnapKit

final class HomeNavigationBarView: UIView {
    
    // MARK: - Callbacks
    
    var onTapSetting: (() -> Void)?
    var onCalendarTap: (() -> Void)?
    
    // MARK: - UI Components
    
    private lazy var titleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .Logo.moaTypo)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let calendarButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(resource: .Icon.iconCalendar).withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = AppColor.IconAndText.highEmphasis
        return button
    }()
    
    private let settingButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(resource: .Icon.iconSetting).withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = AppColor.IconAndText.highEmphasis
        return button
    }()
    
    private lazy var rightStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [calendarButton, settingButton])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 0
        return stack
    }()
    
    private lazy var containerStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            titleImageView,
            UIView(),
            rightStackView
        ])
        stack.axis = .horizontal
        stack.alignment = .center
        return stack
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        setupActions()
    }
    
    convenience init(onTapSetting: (() -> Void)?) {
        self.init(frame: .zero)
        self.onTapSetting = onTapSetting
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Layout
    
    private func setupLayout() {
        
        addSubview(containerStackView)
        
        containerStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        containerStackView.isLayoutMarginsRelativeArrangement = true
        containerStackView.layoutMargins = UIEdgeInsets(
            top: 0,
            left: 4,
            bottom: 0,
            right: 4
        )
        
        calendarButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.size.equalTo(CGSize(width: 44, height: 44))
        }
        
        settingButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.size.equalTo(CGSize(width: 44, height: 44))
        }
        
        calendarButton.addTarget(self, action: #selector(handleCalendarTap), for: .touchUpInside)
    }
    // MARK: - Action

    
    private func setupActions() {
        settingButton.addTarget(self, action: #selector(didTapSetting), for: .touchUpInside)
    }
    
    @objc private func didTapSetting() {
        onTapSetting?()
    }
    
    @objc private func handleCalendarTap() {
        onCalendarTap?()
    }
}
