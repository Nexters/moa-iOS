//
//  PayrollWorkPolicyInfoViewController.swift
//  Moa
//
//  Created by mirim on 2/21/26.
//

import UIKit
import SnapKit

final class PayrollWorkPolicyInfoViewController: BaseViewController {
    
    // MARK: - Constants
    
    private enum Constants {
        static let account = "가입 계정"
        static let payrollInfo = "월급 정보"
        static let payroll = "급여"
        static let payday = "월급일"
        static let workingInfo = "근무 정보"
        static let companyName = "회사명"
        static let unregistered = "미등록"
        static let workingDays = "근무 요일"
        static let workingHours = "근무 시간"
        static let navigationTitle = "월급 · 근무 정보"
    }
    
    // MARK: - Dependencies
    
    private let viewModel: PayrollWorkPolicyInfoViewModel
    
    // MARK: - UI Components
    
    private lazy var accountStackView: UIStackView = {
        let stack = UIStackView()
        return stack
    }()
    
    private lazy var payrollInfoStackView: UIStackView = {
        let stack = UIStackView()
        return stack
    }()
    
    private lazy var workPolicyInfoStackView: UIStackView = {
        let stack = UIStackView()
        return stack
    }()
    
    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 24
        return stack
    }()
    
    private var sections: [(title: String, rows: [SettingItemRowView])] = []
    
    // Row references for updates
    private var payrollRow: SettingItemRowView?
    private var paydayRow: SettingItemRowView?
    private var companyRow: SettingItemRowView?
    private var daysRow: SettingItemRowView?
    private var hoursRow: SettingItemRowView?
    private var accountRow: SettingItemRowView?
    
    // MARK: - Init
    
    init(viewModel: PayrollWorkPolicyInfoViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.getInfo()
    }
    
    // MARK: - Actions
    
    override func setupUI() {
        replaceSystemBackButtonWithAppBackButton()
        setupNavigationTitle(as: Constants.navigationTitle)
        view.addSubview(contentStack)

        contentStack.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(AppSpacing.screenHorizontal)
            $0.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide)
        }

        // 섹션 데이터 구성 후 UI 빌드
        sections = makeSections()
        buildSections()
    }
    
    override func setupActions() {
        
    }
    
    @objc private func payrollButtonTapped() {
        
    }
    
    @objc private func paydayButtonTapped() {
        
    }
    
    @objc private func companyNameButtonTapped() {
        
    }
    
    @objc private func workingDaysButtonTapped() {
        
    }
    
    @objc private func workingHoursButtonTapped() {
        
    }
    
    private func buildSections() {
        // 기존 서브뷰 정리 후 재구성
        contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for section in sections {
            let sectionView = SettingSectionView(
                title: section.title,
                rows: section.rows
            )
            contentStack.addArrangedSubview(sectionView)
        }
    }

    private func makeSections() -> [(title: String, rows: [SettingItemRowView])] {
        let payrollRow = SettingItemRowView(title: Constants.payroll)
        payrollRow.onTap = { [weak self] in self?.payrollButtonTapped() }
        self.payrollRow = payrollRow

        let paydayRow = SettingItemRowView(title: Constants.payday)
        paydayRow.onTap = { [weak self] in self?.paydayButtonTapped() }
        self.paydayRow = paydayRow

        let companyRow = SettingItemRowView(title: Constants.companyName)
        companyRow.onTap = { [weak self] in self?.companyNameButtonTapped() }
        self.companyRow = companyRow

        let daysRow = SettingItemRowView(title: Constants.workingDays)
        daysRow.onTap = { [weak self] in self?.workingDaysButtonTapped() }
        self.daysRow = daysRow

        let hoursRow = SettingItemRowView(title: Constants.workingHours)
        hoursRow.onTap = { [weak self] in self?.workingHoursButtonTapped() }
        self.hoursRow = hoursRow

        let accountRow = SettingItemRowView(title: viewModel.accountProvider.displayDescription)
        self.accountRow = accountRow

        let accountRows = [accountRow]
        let payrollRows = [payrollRow, paydayRow]
        let workPolicyRows = [companyRow, daysRow, hoursRow]

        return [
            (title: Constants.account, rows: accountRows),
            (title: Constants.payrollInfo, rows: payrollRows),
            (title: Constants.workingInfo, rows: workPolicyRows)
        ]
    }
    
    override func bind() {
        bindOutput(viewModel.outputs) { [weak self] output in
            switch output {
            case .payrollFetched:
                self?.payrollRow?.updateValue(self?.viewModel.salary)

            case .workPolicyFetched:
                self?.daysRow?.updateValue(self?.viewModel.workingDays)
                self?.hoursRow?.updateValue(self?.viewModel.workingHours)

            case .profileFetched:
                self?.paydayRow?.updateValue(self?.viewModel.payday)
                self?.companyRow?.updateValue(self?.viewModel.workplace)
            }
        }
    }
}

