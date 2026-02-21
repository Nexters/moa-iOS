//
//  ScheduleTypeOptionView.swift
//  Moa
//
//  Created by 정도현 on 2/21/26.
//

import UIKit
import SnapKit

enum ScheduleTypeOptionType {
    case vacation
    case workday
    
    var title: String {
        switch self {
        case .vacation:
            return "휴가"
        case .workday:
            return "근무"
        }
    }
}

final class ScheduleTypeOptionView: UIView {
    
    private let type: ScheduleTypeOptionType
    
    // MARK: - Constants
    
    private enum Constant {
        static let scheduleType = "어떤 일정인가요?"
        static let vacation = "휴가"
        static let workday = "근무"
    }
    
    // MARK: - Public
    
    var onChange: ((ScheduleTypeOptionType) -> Void)?
    
    private var selected: ScheduleTypeOptionType = .workday  {
        didSet { applySelection() }
    }
    
    func setSelected(_ type: ScheduleTypeOptionType, notify: Bool = false) {
        guard selected != type else { return }
        selected = type
        if notify { onChange?(type) }
    }
    
    // MARK: - UI Components
    
    private let titleLabel: UILabel = {
        let label = StyledLabel()
        label.setText(
            Constant.scheduleType,
            style: .init(
                typography: AppTypography.b2_500,
                color: AppColor.IconAndText.mediumEmphasis
            )
        )
        return label
    }()
    
    private let vacationButton = OptionChipButton(title: Constant.vacation)
    private let workButton = OptionChipButton(title: Constant.workday)
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12.0
        stack.alignment = .fill
        stack.distribution = .fillEqually
        return stack
    }()
    
    // MARK: - Init
    
    init(type: ScheduleTypeOptionType) {
        self.type = type
        super.init(frame: .zero)
        
        setupUI()
        setupActions()
        applySelection()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    
    @objc private func vacationTapped() {
        guard selected != .vacation else { return }
        setSelected(.vacation, notify: true)
    }
    
    @objc private func workdayTapped() {
        guard selected != .workday else { return }
        setSelected(.workday, notify: true)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        addSubViews([titleLabel, stackView])
        stackView.addArrangedSubViews([vacationButton, workButton])
        
        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func setupActions() {
        vacationButton.addTarget(self, action: #selector(vacationTapped), for: .touchUpInside)
        workButton.addTarget(self, action: #selector(workdayTapped), for: .touchUpInside)
    }
    
    private func applySelection() {
        vacationButton.isSelected = (selected == .vacation)
        workButton.isSelected = (selected == .workday)
        
        vacationButton.setNeedsUpdateConfiguration()
        workButton.setNeedsUpdateConfiguration()
    }
}
