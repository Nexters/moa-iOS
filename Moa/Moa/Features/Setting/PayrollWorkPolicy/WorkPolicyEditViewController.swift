//
//  WorkPolicyEditViewController.swift
//  Moa
//
//  Created by mirim on 2/22/26.
//

import UIKit
import SnapKit

final class WorkPolicyEditViewController: BaseViewController {
    
    // MARK: - Constants
    
    private enum Constant {
        static let title = "언제 근무하나요?"
        static let workingHours = "근무 시간"
        static let complete = "완료"
    }
    
    // MARK: - Dependencies
    
    private let viewModel: WorkPolicyEditViewModel
    
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
    
    private let completeButton = AppButton()
    
    // MARK: - Init
    
    init(
        viewModel: WorkPolicyEditViewModel
    ) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    override func setupUI() {
        replaceSystemBackButtonWithAppBackButton()
        setupNavigationTitle(as: Constant.workingHours)
        setupButton()
        setupLayout()
        workingTimeRangeRowView.configure(
            start: viewModel.clockInTime.displayString,
            end: viewModel.clockOutTime.displayString
        )
        weekdaySelectionView.setSelectedWeekdays(viewModel.selectedWeekdays, notify: false)
    }
    
    override func setupActions() {
        workingTimeRangeRowView.addTarget(self, action: #selector(workingHoursRowTapped), for: .touchUpInside)
        completeButton.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
        
        weekdaySelectionView.onSelectionChanged = { [weak self] newSelection in
            guard let self else { return }
            self.viewModel.updateSelectedWeekdays(newSelection)
            self.updateCompleteButtonState()
        }
        
        updateCompleteButtonState()
    }
    
    // MARK: - UI Configuration
    
    private func setupButton() {
        completeButton.setTitle(Constant.complete, for: .normal)
        completeButton.applyStyle(.primary())
    }
    
    private func setupLayout() {
        view.addSubViews([contentStack, completeButton])
        
        contentStack.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }
        
        completeButton.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(AppSpacing.screenHorizontal)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(AppSpacing.ctaBottom)
            make.height.greaterThanOrEqualTo(64)
        }
        
        workingTimeRangeRowView.setContentHuggingPriority(.required, for: .vertical)
    }
    
    // MARK: - Actions
    
    @objc private func workingHoursRowTapped() {
        let sheet = TimeSelectionBottomSheet(
            type: .setWorkingHours,
            startTime: viewModel.clockInTime,
            endTime: viewModel.clockOutTime
        )
        
        sheet.delegate = self
        presentBottomSheet(sheet)
    }
    
    @objc private func completeButtonTapped() {
        Task { @MainActor in
            do {
                try await viewModel.updateWorkPolicy()
                navigationController?.popViewController(animated: true)
            } catch {
                // TODO: 에러처리
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func updateCompleteButtonState() {
        completeButton.isEnabled = !viewModel.selectedWeekdays.isEmpty
    }
}

// MARK: BottomSheetDelegate

extension WorkPolicyEditViewController: TimeSelectionBottomSheetDelegate {
    func timeSelectionBottomSheet(
        _ sheet: TimeSelectionBottomSheet,
        didConfirmStartTime startTime: TimeIndicatorEntity,
        endTime: TimeIndicatorEntity
    ) {
        viewModel.workingHoursConfirmFromBottomSheet(start: startTime, end: endTime)
        workingTimeRangeRowView.configure(start: startTime.displayString, end: endTime.displayString)
    }
}
