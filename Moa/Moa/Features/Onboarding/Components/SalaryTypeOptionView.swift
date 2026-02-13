//
//  SalaryTypeOptionView.swift
//  Moa
//
//  Created by mirim on 2/5/26.
//

import UIKit
import SnapKit

final class SalaryTypeOptionView: UIView {
    
    // MARK: - Constants
    
    private enum Constant {
        static let salaryType = "급여 유형"
        static let monthly = "월급"
        static let yearly = "연봉"
    }
    
    // MARK: - Public
    
    var onChange: ((SalaryType) -> Void)?
    
    private var selected: SalaryType = .yearly {
        didSet { applySelection() }
    }
    
    func setSelected(_ type: SalaryType, notify: Bool = false) {
        guard selected != type else { return }
        selected = type
        if notify { onChange?(type) }
    }
    
    // MARK: - UI Components
    
    private let titleLabel: UILabel = {
        let label = StyledLabel()
        label.setText(
            Constant.salaryType,
            style: .init(
                typography: AppTypography.b2_500,
                color: AppColor.IconAndText.mediumEmphasis
            )
        )
        return label
    }()
    
    private let monthlyButton = OptionChipButton(title: Constant.monthly)
    private let yearlyButton = OptionChipButton(title: Constant.yearly)
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12.0
        stack.alignment = .fill
        stack.distribution = .fillEqually
        return stack
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupActions()
        applySelection()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    
    @objc private func monthlyTapped() {
        guard selected != .monthly else { return }
        setSelected(.monthly, notify: true)
    }
    
    @objc private func yearlyTapped() {
        guard selected != .yearly else { return }
        setSelected(.yearly, notify: true)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        addSubViews([titleLabel, stackView])
        stackView.addArrangedSubViews([yearlyButton, monthlyButton])
        
        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func setupActions() {
        yearlyButton.addTarget(self, action: #selector(yearlyTapped), for: .touchUpInside)
        monthlyButton.addTarget(self, action: #selector(monthlyTapped), for: .touchUpInside)
    }
    
    private func applySelection() {
        yearlyButton.isSelected = (selected == .yearly)
        monthlyButton.isSelected = (selected == .monthly)
        
        yearlyButton.setNeedsUpdateConfiguration()
        monthlyButton.setNeedsUpdateConfiguration()
    }
}
