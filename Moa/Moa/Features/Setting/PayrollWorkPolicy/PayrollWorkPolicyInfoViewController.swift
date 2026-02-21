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
    }
    
    // MARK: - Dependencies
    
    private let viewModel = PayrollWorkPolicyInfoViewModel()
    
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
    
    // 섹션 스택 (타이틀 + 행들을 수직으로 쌓는 컨테이너)
    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 24
        return stack
    }()

    // 화면을 구성할 섹션 데이터 (타이틀 + 행 배열)
    private var sections: [(title: String, rows: [SettingItemRowView])] = []
    
    // MARK: - Actions
    
    override func setupUI() {
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
        let payrollRow = SettingItemRowView(title: Constants.payroll, value: "연봉 3,600만원")
        payrollRow.onTap = { [weak self] in self?.payrollButtonTapped() }

        let paydayRow = SettingItemRowView(title: Constants.payday, value: "매월 25일")
        paydayRow.onTap = { [weak self] in self?.paydayButtonTapped() }

        let companyRow = SettingItemRowView(title: Constants.companyName, value: Constants.unregistered)
        companyRow.onTap = { [weak self] in self?.companyNameButtonTapped() }

        let daysRow = SettingItemRowView(title: Constants.workingDays, value: "월 화 수 목 금")
        daysRow.onTap = { [weak self] in self?.workingDaysButtonTapped() }

        let hoursRow = SettingItemRowView(title: Constants.workingHours, value: "09:00 - 18:00")
        hoursRow.onTap = { [weak self] in self?.workingHoursButtonTapped() }

        // 섹션 묶기
        let accountRows = [
            SettingItemRowView(title: Constants.account, value: "apple@moa.com")
        ]
        let payrollRows = [payrollRow, paydayRow]
        let workPolicyRows = [companyRow, daysRow, hoursRow]

        return [
            (title: Constants.account, rows: accountRows),
            (title: Constants.payrollInfo, rows: payrollRows),
            (title: Constants.workingInfo, rows: workPolicyRows)
        ]
    }
}
