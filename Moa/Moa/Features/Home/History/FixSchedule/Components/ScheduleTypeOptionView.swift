//
//  ScheduleTypeOptionView.swift
//  Moa
//
//  Created by 정도현 on 2/21/26.
//

import UIKit
import SnapKit

final class ScheduleTypeOptionView: UIView {
    
    private let type: ScheduleTypeOptionType
    
    // MARK: - Public
    
    var onChange: ((ScheduleTypeOptionType) -> Void)?
    
    private var selected: ScheduleTypeOptionType = .workday {
        didSet { applySelection() }
    }
    
    private var buttons: [ScheduleTypeOptionType: OptionChipButton] = [:]
    
    // MARK: - UI
    
    private let titleLabel: UILabel = {
        let label = StyledLabel()
        label.setText(
            "어떤 일정인가요?",
            style: .init(
                typography: AppTypography.b2_500,
                color: AppColor.IconAndText.mediumEmphasis
            )
        )
        return label
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillEqually
        return stack
    }()
    
    // MARK: - Init
    
    init(type: ScheduleTypeOptionType) {
        self.type = type
        super.init(frame: .zero)
        
        setupUI()
        setupButtons()
        applySelection()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Setup
    
    private func setupUI() {
        addSubViews([titleLabel, stackView])
        
        titleLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        
        stackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func setupButtons() {
        let types: [ScheduleTypeOptionType] = [.workday, .vacation, .none]
        
        types.forEach { type in
            let button = OptionChipButton(title: type.title)
            button.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
            
            stackView.addArrangedSubview(button)
            buttons[type] = button
        }
    }
    
    // MARK: - Actions
    
    @objc private func didTapButton(_ sender: UIButton) {
        guard let (type, _) = buttons.first(where: { $0.value == sender }) else { return }
        guard selected != type else { return }
        
        selected = type
        onChange?(type)
    }
    
    // MARK: - Public
    
    func setSelected(_ type: ScheduleTypeOptionType, notify: Bool = false) {
        guard selected != type else { return }
        selected = type
        if notify { onChange?(type) }
    }
    
    // MARK: - UI Update
    
    private func applySelection() {
        buttons.forEach { type, button in
            button.isSelected = (type == selected)
            button.setNeedsUpdateConfiguration()
        }
    }
}
