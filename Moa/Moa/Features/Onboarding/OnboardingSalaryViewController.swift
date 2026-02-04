//
//  OnboardingSalaryViewController.swift
//  Moa
//
//  Created by mirim on 2/3/26.
//

import UIKit
import SnapKit

final class OnboardingSalaryViewController: BaseViewController {
    // MARK: - Constants
    
    private enum Constant {
        static let title = "얼마씩 받고 있나요?"
        static let subtitle = "세전, 세후 상관없이 보고 싶은 금액을 입력해주세요."
        static let salaryType = "급여 유형"
        static let monthlySalary = "월급"
        static let annualSalary = "연봉"
        static let amount = "금액"
        static let won = "원"
    }
    
    // MARK: - Dependencies
    
    private let viewModel: OnboardingSalaryViewModel
    private let onNext: (() -> Void)
    
    // MARK: - Init
    
    init(
        viewModel: OnboardingSalaryViewModel,
        onNext: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.onNext = onNext
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    override func setupUI() {
        replaceSystemBackButtonWithAppBackButton()
    }
}
