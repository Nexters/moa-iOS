//
//  OnboardingWorkPolicyViewController.swift
//  Moa
//
//  Created by mirim on 2/5/26.
//

import UIKit
import SnapKit

final class OnboardingWorkPolicyViewController: BaseViewController {
    
    // MARK: - Constants
    
    private enum Constant {
        static let title = "언제 근무하나요?"
        static let workingHours = "근무 시간"
        static let lunchBreakTime = "점심 · 휴게 시간"
    }
    
    // MARK: - Dependencies
    
    private let viewModel: OnboardingWorkPolicyViewModel
    private let onNext: (() -> Void)
    
    // MARK: - UI Components
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = Constant.title
        label.applyTextStyle(.init(
            typography: AppTypography.t1_700,
            color: AppColor.IconAndText.highEmphasis
        ))
        return label
    }()
    
    private let weekdaySelectionView = WeekdaySelectionView()
    
    // MARK: - Init
    
    init(
        viewModel: OnboardingWorkPolicyViewModel,
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
        setupLayout()
    }
    
    private func setupLayout() {
        view.addSubViews([titleLabel, weekdaySelectionView])
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(AppSpacing.screenHorizontal)
        }
        
        weekdaySelectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(32)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(AppSpacing.screenHorizontal)
        }
    }
}
