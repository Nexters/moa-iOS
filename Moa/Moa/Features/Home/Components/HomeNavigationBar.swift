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
        imageView.image = UIImage(resource: .moaTypoLogo)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var calendarButton: AppIconButton = {
        AppIconButton(image: UIImage(resource: .Icon.iconCalendar))
    }()
    
    private lazy var settingButton: AppIconButton = {
        AppIconButton(image: UIImage(resource: .Icon.iconSetting))
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
        
        titleImageView.snp.makeConstraints {
            $0.top.bottom.equalTo(containerStackView)
            $0.leading.equalToSuperview().inset(4)
        }
    }
}
