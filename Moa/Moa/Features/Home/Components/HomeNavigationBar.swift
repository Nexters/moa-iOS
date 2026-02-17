//
//  HomeNavigationBar.swift
//  Moa
//
//  Created by 정도현 on 2/1/26.
//

import UIKit
import SnapKit

final class HomeNavigationBarView: UIView {
    
    // MARK: - UI Components
    
    private lazy var titleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .Logo.moaTypo)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var calendarButton: AppIconButton = {
        AppIconButton(
            image: UIImage(resource: .Icon.iconCalendar),
            tintColor: AppColor.IconAndText.highEmphasis
        )
    }()
    
    private lazy var settingButton: AppIconButton = {
        AppIconButton(
            image: UIImage(resource: .Icon.iconSetting),
            tintColor: AppColor.IconAndText.highEmphasis
        )
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
            right: 0
        )
    }

}
