//
//  HomeViewController.swift
//  Moa
//
//  Created by 정도현 on 2/1/26.
//

import UIKit
import SnapKit

final class HomeViewController: BaseViewController {

    // MARK: - UI

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private lazy var navigationBarView = HomeNavigationBarView()

    private lazy var monthlySalaryView = MonthlySalaryView(
        month: 2,
        amount: 1_500_000,
        baseAmount: 1_200_000,
        shouldAnimate: true
    )

    private lazy var todayWorkSummaryView = TodayWorkSummaryView(
        wage: "150,000원",
        workTime: "09:00 - 18:00"
    )
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubViews([navigationBarView, monthlySalaryView, todayWorkSummaryView])

        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }

        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        // Navigation Bar
        navigationBarView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(56)
        }

        // Monthly Salary
        monthlySalaryView.snp.makeConstraints {
            $0.top.equalTo(navigationBarView.snp.bottom).offset(54)
            $0.leading.trailing.equalToSuperview().inset(17)
        }

        // Today Work Summary
        todayWorkSummaryView.snp.makeConstraints {
            $0.top.equalTo(monthlySalaryView.snp.bottom).offset(36)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(24)
        }
    }
}

@available(iOS 17.0)
#Preview {
    HomeViewController()
}
