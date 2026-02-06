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
        static let next = "다음"
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
    
    private let workingHoursLabel: UILabel = {
        let label = UILabel()
        label.text = Constant.workingHours
        label.applyTextStyle(.init(
            typography: AppTypography.b2_500,
            color: AppColor.IconAndText.mediumEmphasis
        ))
        return label
    }()
    
    private let workingTimeRangeRowView = TimeRangeRowView()
    
    private let lunchBreakTimeLabel: UILabel = {
        let label = UILabel()
        label.text = Constant.lunchBreakTime
        label.applyTextStyle(.init(
            typography: AppTypography.b2_500,
            color: AppColor.IconAndText.mediumEmphasis
        ))
        return label
    }()
    
    private let lunchBreakTimeRangeRowView = TimeRangeRowView()
    
    private let nextButton = AppButton()
    
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
        setupButton()
        setupLayout()
        lunchBreakTimeRangeRowView.configure(start: "12:00", end: "13:00")
    }
    
    override func setupActions() {
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        
        weekdaySelectionView.onSelectionChanged = { [weak self] _ in
            self?.updateNextButtonState()
        }
        
        updateNextButtonState()
    }
    
    // MARK: - UI Configuration
    
    private func setupButton() {
        nextButton.setTitle(Constant.next, for: .normal)
        nextButton.applyStyle(.primary())
    }
    
    private func setupLayout() {
        view.addSubViews([
            titleLabel,
            weekdaySelectionView,
            workingHoursLabel,
            workingTimeRangeRowView,
            lunchBreakTimeLabel,
            lunchBreakTimeRangeRowView,
            nextButton
        ])
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(AppSpacing.screenHorizontal)
        }
        
        weekdaySelectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(32)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(AppSpacing.screenHorizontal)
        }
        
        workingHoursLabel.snp.makeConstraints { make in
            make.top.equalTo(weekdaySelectionView.snp.bottom).offset(24)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(AppSpacing.screenHorizontal)
        }
        
        workingTimeRangeRowView.snp.makeConstraints { make in
            make.top.equalTo(workingHoursLabel.snp.bottom).offset(8)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(AppSpacing.screenHorizontal)
        }
        
        lunchBreakTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(workingTimeRangeRowView.snp.bottom).offset(24)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(AppSpacing.screenHorizontal)
        }
        
        lunchBreakTimeRangeRowView.snp.makeConstraints { make in
            make.top.equalTo(lunchBreakTimeLabel.snp.bottom).offset(8)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(AppSpacing.screenHorizontal)
        }
        
        nextButton.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(AppSpacing.screenHorizontal)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(AppSpacing.ctaBottom)
            make.height.greaterThanOrEqualTo(64)
        }
        
        workingTimeRangeRowView.setContentHuggingPriority(.required, for: .vertical)
        lunchBreakTimeRangeRowView.setContentHuggingPriority(.required, for: .vertical)
    }
    
    // MARK: - Actions
    
    @objc private func nextButtonTapped() {
        onNext()
    }
    
    // MARK: - Private Methods
    
    private func updateNextButtonState() {
        nextButton.isEnabled = !weekdaySelectionView.selectedWeekdays.isEmpty
    }
}
