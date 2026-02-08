//
//  HomeViewController.swift
//  Moa
//
//  Created by 정도현 on 2/1/26.
//

import UIKit
import SnapKit

final class HomeViewController: BaseViewController {
    override var prefersNavigationBarHidden: Bool {
        true
    }
    
    // MARK: - Constants
    private enum Constant {
        static let autoWorkSuffix = "자동 출근 예정"
        static let earlyWork = "일찍 출근하기"
        static let todayVacation = "오늘 휴가예요"
        
        static let navigationBarHeight: CGFloat = 56
        static let salaryInset: CGFloat = 17
        static let actionSpacing: CGFloat = 16
        static let bottomInset: CGFloat = 24
    }
    
    // MARK: - UI
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let navigationBarView = HomeNavigationBarView()
    
    // Main Info Group
    private let mainInfoContainerView = UIView()
    
    private let dateLocationInfoView = DateLocationInfoView(
        date: "test",
        location: "을지로 을지로"
    )
    
    private let moneyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .Image.imageEmptyMoney)
        return imageView
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
    
    // Bottom Action Group
    private let bottomActionContainerView = UIView()
    
    private lazy var autoWorkIndicator: SpeechBubble = {
        let view = SpeechBubble(text: "09:00 \(Constant.autoWorkSuffix)")
        return view
    }()
    
    private let startWorkButton: AppButton = {
        let button = AppButton()
        button.setTitle(Constant.earlyWork, for: .normal)
        button.applyStyle(.primary())
        return button
    }()
    
    private let underlineButton = UnderlineTextButton(
        title: Constant.todayVacation
    )
    
    // MARK: - Lifecycle
    
    override func setupUI() {
        setupHierarchy()
        setupConstraints()
    }
}


// MARK: - Layout
private extension HomeViewController {
    
    func setupHierarchy() {
        view.addSubViews([scrollView, bottomActionContainerView])
        scrollView.addSubview(contentView)
        
        contentView.addSubViews([
            navigationBarView,
            mainInfoContainerView,
            todayWorkSummaryView
        ])
        
        mainInfoContainerView.addSubViews([
            dateLocationInfoView,
            moneyImageView,
            monthlySalaryView
        ])
        
        bottomActionContainerView.addSubViews([
            autoWorkIndicator,
            startWorkButton,
            underlineButton
        ])
    }
    func setupConstraints() {
        
        // Scroll
        scrollView.contentInset.bottom = 64 + startWorkButton.intrinsicContentSize.height + 16
        
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
        }
        
        // Navigation
        navigationBarView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(Constant.navigationBarHeight)
        }
        
        // Main Info Group
        mainInfoContainerView.snp.makeConstraints {
            $0.top.equalTo(navigationBarView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview()
        }
        
        dateLocationInfoView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
        
        moneyImageView.snp.makeConstraints {
            $0.top.equalTo(dateLocationInfoView.snp.bottom).offset(28)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(80)
        }
        
        monthlySalaryView.snp.makeConstraints {
            $0.top.equalTo(moneyImageView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(Constant.salaryInset)
            $0.bottom.equalToSuperview()
        }
        
        // Summary
        todayWorkSummaryView.snp.makeConstraints {
            $0.top.equalTo(mainInfoContainerView.snp.bottom).offset(36)
            $0.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
        }
        
        // Bottom Action Group
        bottomActionContainerView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        autoWorkIndicator.snp.makeConstraints {
            $0.centerX.equalToSuperview()
        }
        
        startWorkButton.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
            $0.top.equalTo(autoWorkIndicator.snp.bottom).offset(12)
        }
        
        underlineButton.snp.makeConstraints {
            $0.top.equalTo(startWorkButton.snp.bottom).offset(Constant.actionSpacing)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(Constant.bottomInset)
        }
    }
}
