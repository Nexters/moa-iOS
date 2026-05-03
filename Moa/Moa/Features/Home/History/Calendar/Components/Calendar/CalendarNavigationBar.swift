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
    private let type: CalendarNavigationType
    
    // MARK: - UI
    
    private let prevButton = UIButton(type: .system)
    private let monthLabel = StyledLabel()
    private let nextButton = UIButton(type: .system)
    private let addButton  = UIButton(type: .system)
    
    private let monthStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.alignment = .center
        sv.distribution = .equalSpacing
        return sv
    }()
    
    // MARK: - Init
    
    init(type: CalendarNavigationType) {
        self.type = type
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Setup
    
    private func setup() {
        configureUI()
        configureLayout()
        configureActions()
    }
    
    private func configureUI() {
        prevButton.setImage(UIImage(resource: .Icon.iconChevronLeft), for: .normal)
        nextButton.setImage(UIImage(resource: .Icon.iconChevronRight), for: .normal)
        
        [prevButton, nextButton].forEach {
            $0.tintColor = AppColor.IconAndText.highEmphasis
        }
        
        monthLabel.setStyle(.init(
            typography: AppTypography.t2_500,
            color: AppColor.IconAndText.highEmphasis
        ))
        monthLabel.textAlignment = .center
        
        addButton.backgroundColor    = AppColor.Container.secondary
        addButton.layer.cornerRadius = 16
        addButton.setImage(UIImage(resource: .Icon.iconWrite), for: .normal)
        addButton.tintColor          = AppColor.IconAndText.highEmphasis
    }
    
    private func configureLayout() {
        monthStackView.addArrangedSubview(prevButton)
        monthStackView.addArrangedSubview(monthLabel)
        monthStackView.addArrangedSubview(nextButton)
        
        addSubview(monthStackView)
        
        if type.showsAddButton {
            addSubview(addButton)
        }
        
        switch type {
        case .history:
            monthStackView.snp.makeConstraints {
                $0.leading.equalToSuperview()
                $0.centerY.equalToSuperview()
                $0.width.equalTo(100)
            }
            addButton.snp.makeConstraints {
                $0.trailing.centerY.equalToSuperview()
                $0.size.equalTo(32)
            }
        case .bottomSheet:
            monthStackView.snp.makeConstraints {
                $0.center.equalToSuperview()
                $0.width.equalTo(100)
            }
        }
        
        prevButton.snp.makeConstraints { $0.size.equalTo(24) }
        nextButton.snp.makeConstraints { $0.size.equalTo(24) }
        addButton.snp.makeConstraints  { $0.size.equalTo(32) }
    }
    
    private func configureActions() {
        prevButton.addTarget(self, action: #selector(tappedPrev), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(tappedNext), for: .touchUpInside)
        addButton.addTarget(self,  action: #selector(tappedAdd),  for: .touchUpInside)
    }
    
    // MARK: - Public

    func setTitle(_ title: String) {
        monthLabel.setText(title)
    }

    /// 이전 달 버튼 활성/비활성
    func setPrevButtonEnabled(_ enabled: Bool) {
        prevButton.isEnabled = enabled
        prevButton.tintColor = enabled
            ? AppColor.IconAndText.highEmphasis
            : AppColor.IconAndText.disabled
    }

    /// 다음 달 버튼 활성/비활성
    func setNextButtonEnabled(_ enabled: Bool) {
        nextButton.isEnabled = enabled
        nextButton.tintColor = enabled
            ? AppColor.IconAndText.highEmphasis
            : AppColor.IconAndText.disabled
    }
    
    // MARK: - Actions
    
    @objc private func tappedPrev() { delegate?.navigationBarDidTapPrev() }
    @objc private func tappedNext() { delegate?.navigationBarDidTapNext() }
    @objc private func tappedAdd()  {
        Analytics.track(.calendarEditClicked)
        delegate?.navigationBarDidTapAdd()
    }
}
