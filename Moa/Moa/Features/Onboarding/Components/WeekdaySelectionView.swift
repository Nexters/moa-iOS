//
//  WeekdaySelectionView.swift
//  Moa
//
//  Created by mirim on 2/6/26.
//

import UIKit
import SnapKit

final class WeekdaySelectionView: UIView {
    
    // MARK: - Constants
    
    private enum Constant {
        static let workDays = "근무 요일"
        static let topSpacing: CGFloat = 8
        static let weekDaySpacing: CGFloat = 8
    }
    
    // MARK: - Output
    
    var onSelectionChanged: ((Set<Weekday>) -> Void)?
    
    // MARK: - State
    
    private(set) var selectedWeekdays: Set<Weekday> = [] {
        didSet { updateChipSelectionUI() }
    }
    
    private var chipButtons: [Weekday: WeekdayChipButton] = [:]
    
    // MARK: - UI Components
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = Constant.workDays
        label.applyTextStyle(.init(
            typography: AppTypography.b2_500,
            color: AppColor.IconAndText.mediumEmphasis
        ))
        return label
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = Constant.weekDaySpacing
        return stack
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupWeekdayChips()
        updateChipSelectionUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    
    func setSelectedWeekdays(_ weekdays: Set<Weekday>, notify: Bool = false) {
        selectedWeekdays = weekdays
        if notify { onSelectionChanged?(selectedWeekdays) }
    }
    
    // MARK: - Private
    
    private func setupUI() {
        addSubViews([titleLabel, stackView])
        
        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Constant.topSpacing)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func setupWeekdayChips() {
        Weekday.ordered.forEach { weekday in
            let btn = WeekdayChipButton(title: weekday.displayName)
            btn.tag = weekday.rawValue
            btn.addTarget(self, action: #selector(chipTapped(_:)), for: .touchUpInside)
            
            chipButtons[weekday] = btn
            stackView.addArrangedSubview(btn)
        }
    }
    
    @objc private func chipTapped(_ sender: UIButton) {
        guard let weekday = Weekday(rawValue: sender.tag) else { return }
        
        if selectedWeekdays.contains(weekday) {
            selectedWeekdays.remove(weekday)
        } else {
            selectedWeekdays.insert(weekday)
        }
        
        onSelectionChanged?(selectedWeekdays)
    }
    
    private func updateChipSelectionUI() {
        for (weekday, button) in chipButtons {
            button.isSelected = selectedWeekdays.contains(weekday)
        }
    }
}
