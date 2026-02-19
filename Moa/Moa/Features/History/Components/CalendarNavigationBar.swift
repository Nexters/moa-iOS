//
//  CalendarNavigationBar.swift
//  Moa
//
//  Created by 정도현 on 2/19/26.
//

import UIKit
import SnapKit

protocol CalendarNavigationBarDelegate: AnyObject {
    func navigationBarDidTapPrev()
    func navigationBarDidTapNext()
    func navigationBarDidTapAdd()
}

final class CalendarNavigationBar: UIView {
    
    weak var delegate: CalendarNavigationBarDelegate?
    
    private let prevButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(resource: .Icon.iconChevronLeft), for: .normal)
        b.tintColor = AppColor.IconAndText.highEmphasis
        return b
    }()
    
    private let monthLabel: StyledLabel = {
        let l = StyledLabel()
        l.setStyle(.init(typography: AppTypography.t2_500, color: AppColor.IconAndText.highEmphasis))
        l.textAlignment = .center
        return l
    }()
    
    private let nextButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(resource: .Icon.iconChevronRight), for: .normal)
        b.tintColor = AppColor.IconAndText.highEmphasis
        return b
    }()
    
    private let addButton: UIButton = {
        let b = UIButton(type: .system)
        b.backgroundColor = AppColor.Container.secondary
        b.layer.cornerRadius = 16
        b.clipsToBounds = true
        b.setImage(UIImage(resource: .Icon.iconPlus), for: .normal)
        b.tintColor = AppColor.IconAndText.highEmphasis
        return b
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) { fatalError() }
    
    private func setup() {
        [prevButton, monthLabel, nextButton, addButton].forEach { addSubview($0) }
        
        prevButton.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
            $0.size.equalTo(CGSize(width: 24, height: 24))
        }

        monthLabel.snp.makeConstraints {
            $0.leading.equalTo(prevButton.snp.trailing).offset(12)
            $0.width.equalTo(36)
            $0.centerY.equalToSuperview()
        }

        nextButton.snp.makeConstraints {
            $0.leading.equalTo(monthLabel.snp.trailing).offset(12)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(CGSize(width: 24, height: 24))
        }

        addButton.snp.makeConstraints {
            $0.trailing.centerY.equalToSuperview()
            $0.size.equalTo(CGSize(width: 32, height: 32))
        }
        
        prevButton.addTarget(self, action: #selector(tappedPrev), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(tappedNext), for: .touchUpInside)
        addButton.addTarget(self, action: #selector(tappedAdd), for: .touchUpInside)
    }
    
    func setTitle(_ title: String) { monthLabel.setText(title) }
    
    func setNextEnabled(_ enabled: Bool) {
        nextButton.isEnabled = enabled
        nextButton.tintColor = enabled
            ? AppColor.IconAndText.highEmphasis
            : AppColor.IconAndText.disabled
    }
    
    @objc private func tappedPrev() { delegate?.navigationBarDidTapPrev() }
    @objc private func tappedNext() { delegate?.navigationBarDidTapNext() }
    @objc private func tappedAdd()  { delegate?.navigationBarDidTapAdd()  }
}
