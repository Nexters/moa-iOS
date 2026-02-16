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
        static let next = "다음"
    }
    
    // MARK: - Dependencies
    
    private let viewModel: OnboardingWorkPolicyViewModel
    private let onNext: (() -> Void)
    
    // MARK: - UI Components
    
    private let titleLabel: UILabel = {
        let label = StyledLabel()
        label.setText(
            Constant.title,
            style: .init(
                typography: AppTypography.t1_700,
                color: AppColor.IconAndText.highEmphasis
            )
        )
        return label
    }()
    
    private let weekdaySelectionView = WeekdaySelectionView()
    
    private let workingHoursLabel: UILabel = {
        let label = StyledLabel()
        label.setText(
            Constant.workingHours,
            style: .init(
                typography: AppTypography.b2_500,
                color: AppColor.IconAndText.mediumEmphasis
            )
        )
        return label
    }()
    
    private let workingTimeRangeRowView = TimeRangeRowView()
    
    private lazy var workingHourSection: UIStackView = {
        let v = UIStackView(arrangedSubviews: [workingHoursLabel, workingTimeRangeRowView])
        v.axis = .vertical
        v.spacing = 8
        return v
    }()

    private lazy var contentStack: UIStackView = {
        let v = UIStackView(arrangedSubviews: [
            titleLabel,
            weekdaySelectionView,
            workingHourSection
        ])
        v.axis = .vertical
        v.alignment = .fill
        v.spacing = 24
        v.isLayoutMarginsRelativeArrangement = true
        v.directionalLayoutMargins = .init(
            top: 20,
            leading: AppSpacing.screenHorizontal,
            bottom: 0,
            trailing: AppSpacing.screenHorizontal
        )
        
        v.setCustomSpacing(32, after: titleLabel)
        return v
    }()
    
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
        let startTime = viewModel.clockInTime ?? "09:00"
        let endTime = viewModel.clockOutTime ?? "18:00"
        workingTimeRangeRowView.configure(start: startTime, end: endTime)
        weekdaySelectionView.setSelectedWeekdays(viewModel.selectedWeekdays, notify: false)
    }
    
    override func setupActions() {
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        
        weekdaySelectionView.onSelectionChanged = { [weak self] newSelection in
            guard let self else { return }
            self.viewModel.updateSelectedWeekdays(newSelection)
            self.updateNextButtonState()
        }
        
        updateNextButtonState()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if viewModel.shouldPresentTermsSheet, !viewModel.hasPresentedTermsSheet {
            viewModel.markTermsSheetPresented()
            
            DispatchQueue.main.async { [weak self] in
                self?.showTermsAgreementBottomSheet()
            }
        }
    }
    
    // MARK: - UI Configuration
    
    private func setupButton() {
        nextButton.setTitle(Constant.next, for: .normal)
        nextButton.applyStyle(.primary())
    }
    
    private func setupLayout() {
        view.addSubViews([contentStack, nextButton])
        
        contentStack.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }
        
        nextButton.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(AppSpacing.screenHorizontal)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(AppSpacing.ctaBottom)
            make.height.greaterThanOrEqualTo(64)
        }
        
        workingTimeRangeRowView.setContentHuggingPriority(.required, for: .vertical)
    }
    
    // MARK: - Actions
    
    @objc private func nextButtonTapped() {
        showTermsAgreementBottomSheet()
    }
    
    private func showTermsAgreementBottomSheet() {
        let vc = ConsentBottomSheetViewController()
        
        vc.delegate = self
        presentBottomSheet(vc)
    }
    
    // MARK: - Private Methods
    
    private func updateNextButtonState() {
        nextButton.isEnabled = !viewModel.selectedWeekdays.isEmpty
    }
}

// MARK: BottomSheetDelegate

extension OnboardingWorkPolicyViewController: ConsentBottomSheetViewDelegate {
    func didTapConfirm() {
        onNext()
    }
}
