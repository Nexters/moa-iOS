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

    private let navigationBarView = HomeNavigationBarView()

    private let dateLocationInfoView = DateLocationInfoView(
        date: "test",
        location: "을지로 을지로"
    )
    
    private lazy var moneyImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(resource: .Image.imageEmptyMoney)
        return view
    }()

    private let monthlySalaryView = MonthlySalaryView(
        month: 2,
        amount: 1_500_000,
        baseAmount: 1_200_000,
        shouldAnimate: true
    )

    private let todayWorkSummaryView = TodayWorkSummaryView(
        wage: "150,000원",
        workTime: "09:00 - 18:00"
    )

    // MARK: - Lifecycle

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    override func setupUI() {
        setupHierarchy()
        setupConstraints()
    }
}

// MARK: - Layout
private extension HomeViewController {

    func setupHierarchy() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubViews([
            navigationBarView,
            moneyImageView,
            dateLocationInfoView,
            monthlySalaryView,
            todayWorkSummaryView
        ])
    }

    func setupConstraints() {
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }

        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
        }

        navigationBarView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(56)
        }
        
        dateLocationInfoView.snp.makeConstraints {
            $0.top.equalTo(navigationBarView.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
        }
        
        moneyImageView.snp.makeConstraints {
            $0.top.equalTo(dateLocationInfoView.snp.bottom).offset(28)
            $0.width.height.equalTo(80)
            $0.centerX.equalToSuperview()
        }

        monthlySalaryView.snp.makeConstraints {
            $0.top.equalTo(moneyImageView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(17)
        }

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
