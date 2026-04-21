//
//  FixScheduleViewController.swift
//  Moa
//
//  Created by 정도현 on 2/21/26.
//

import UIKit
import Combine
import SnapKit

// MARK: - Coordinator Delegate

protocol FixScheduleViewControllerDelegate: AnyObject {
    func fixScheduleViewControllerDidCancel(_ vc: FixScheduleViewController)
    func fixScheduleViewControllerDidConfirm(_ vc: FixScheduleViewController,
                                             state: FixScheduleViewState)
}

enum ScheduleTypeOptionViewType {
    case add
    case fix

    var title: String {
        switch self {
        case .add: return "추가"
        case .fix: return "수정"
        }
    }
}

// MARK: - FixScheduleViewController

final class FixScheduleViewController: BaseViewController {

    // MARK: - Properties

    private let viewModel: FixScheduleViewModel
    weak var coordinatorDelegate: FixScheduleViewControllerDelegate?

    // MARK: - UI — 타이틀

    private lazy var titleLabel: StyledLabel = {
        let label = StyledLabel()
        label.setText(
            "일정을 \(viewModel.viewType.title)해주세요",
            style: .init(
                typography: AppTypography.t1_700,
                color: AppColor.IconAndText.highEmphasis
            )
        )
        label.numberOfLines = 2
        return label
    }()

    // MARK: - UI — 날짜 구간 섹션

    private let dateSectionLabel: StyledLabel = {
        let label = StyledLabel()
        label.setText(
            "날짜를 선택해주세요",
            style: .init(
                typography: AppTypography.b2_500,
                color: AppColor.IconAndText.mediumEmphasis
            )
        )
        return label
    }()

    private lazy var dateRangeCardView: ScheduleDateRangeCardView = {
        let view = ScheduleDateRangeCardView()
        view.onTap = { [weak self] in
            guard let self, self.viewModel.isDateSelectable else { return }
            self.presentDatePicker()
        }
        return view
    }()

    // MARK: - UI — 일정 타입 섹션

    private lazy var scheduleTypeOptionView: ScheduleTypeOptionView = {
        let view = ScheduleTypeOptionView(type: .vacation)
        view.onChange = { [weak self] type in
            self?.viewModel.send(.selectScheduleType(type))
        }
        return view
    }()

    // MARK: - UI — 근무 시간 섹션

    private let timeSectionLabel: StyledLabel = {
        let label = StyledLabel()
        label.setText(
            "근무 시간",
            style: .init(
                typography: AppTypography.b2_500,
                color: AppColor.IconAndText.mediumEmphasis
            )
        )
        return label
    }()

    private lazy var workingTimeRangeRowView: TimeRangeRowView = {
        let view = TimeRangeRowView()
        view.addTarget(self, action: #selector(didTapTimeRange), for: .touchUpInside)
        return view
    }()

    private lazy var workingHourSection: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [timeSectionLabel, workingTimeRangeRowView])
        sv.axis    = .vertical
        sv.spacing = 8
        return sv
    }()

    // MARK: - UI — 하단 버튼

    private lazy var cancelButton: AppButton = {
        let btn = AppButton()
        btn.setTitle("취소", for: .normal)
        btn.applyStyle(.tertiary())
        btn.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
        return btn
    }()

    private lazy var confirmButton: AppButton = {
        let btn = AppButton()
        btn.setTitle("확인", for: .normal)
        btn.applyStyle(.primary())
        btn.isEnabled = false
        btn.addTarget(self, action: #selector(didTapConfirm), for: .touchUpInside)
        return btn
    }()

    private lazy var bottomButtonStack: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [cancelButton, confirmButton])
        sv.axis         = .horizontal
        sv.spacing      = 12
        sv.distribution = .fillEqually
        return sv
    }()

    // MARK: - Init

    init(viewModel: FixScheduleViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Setup

    override func setupUI() {
        view.backgroundColor = AppColor.Background.primary
        replaceSystemBackButtonWithAppBackButton()
        setupHierarchy()
        setupConstraints()

        let s = viewModel.state
        workingTimeRangeRowView.configure(
            start: s.startTime.displayString,
            end:   s.endTime.displayString
        )

        // 날짜 고정 모드일 때 카드를 시각적으로 비활성 처리
        dateRangeCardView.isUserInteractionEnabled = viewModel.isDateSelectable
    }

    override func bind() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.render($0) }
            .store(in: &cancellables)

        viewModel.$submitState
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.handleSubmitState($0) }
            .store(in: &cancellables)
    }
}

// MARK: - Layout

private extension FixScheduleViewController {

    func setupHierarchy() {
        view.addSubViews([
            titleLabel,
            dateSectionLabel,
            dateRangeCardView,
            scheduleTypeOptionView,
            workingHourSection,
            bottomButtonStack,
        ])
    }

    func setupConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
        }
        dateSectionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
        }
        dateRangeCardView.snp.makeConstraints {
            $0.top.equalTo(dateSectionLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
            $0.height.equalTo(60)
        }
        scheduleTypeOptionView.snp.makeConstraints {
            $0.top.equalTo(dateRangeCardView.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
        }
        workingHourSection.snp.makeConstraints {
            $0.top.equalTo(scheduleTypeOptionView.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
        }
        bottomButtonStack.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(24)
            $0.height.equalTo(64)
        }
    }
}

// MARK: - Render

private extension FixScheduleViewController {

    func render(_ state: FixScheduleViewState) {
        dateRangeCardView.configure(dateRange: state.dateRange)
        scheduleTypeOptionView.setSelected(state.scheduleType)
        workingTimeRangeRowView.configure(
            start: state.startTime.displayString,
            end:   state.endTime.displayString
        )

        if viewModel.submitState != .submitting {
            confirmButton.isEnabled = state.isConfirmEnabled
        }

        workingHourSection.isHidden = (state.scheduleType != .workday)
    }
}

// MARK: - Submit State

private extension FixScheduleViewController {

    func handleSubmitState(_ submitState: FixScheduleSubmitState) {
        switch submitState {

        case .idle:
            break

        case .submitting:
            confirmButton.isEnabled = false
            cancelButton.isEnabled  = false

        case .success:
            coordinatorDelegate?.fixScheduleViewControllerDidConfirm(self, state: viewModel.state)

        case .failure(let message):
            confirmButton.isEnabled = viewModel.state.isConfirmEnabled
            cancelButton.isEnabled  = true
            showErrorAlert(message: message)
        }
    }

    func showErrorAlert(message: String) {
        let vc = MoaAlertViewController(message: "저장 실패")
        present(vc, animated: true)
    }
}

// MARK: - Bottom Sheet Presentation

private extension FixScheduleViewController {

    func presentDatePicker() {
        let sheet = DatePickerCalendarBottomSheet(joinedAt: viewModel.joinedAt)
        sheet.delegate = self
        presentBottomSheet(sheet)
    }

    func presentTimeSelection() {
        let sheet = TimeSelectionBottomSheet(
            type: .setEstimateTime,
            startTime: viewModel.state.startTime,
            endTime:   viewModel.state.endTime
        )
        sheet.delegate = self
        presentBottomSheet(sheet)
    }
}

// MARK: - Actions

extension FixScheduleViewController {

    @objc func didTapBack() {
        coordinatorDelegate?.fixScheduleViewControllerDidCancel(self)
    }

    @objc private func didTapCancel() {
        coordinatorDelegate?.fixScheduleViewControllerDidCancel(self)
    }

    @objc private func didTapConfirm() {
        viewModel.send(.confirmTapped)
    }

    @objc private func didTapTimeRange() {
        presentTimeSelection()
    }
}

// MARK: - DatePickerCalendarBottomSheetDelegate

extension FixScheduleViewController: DatePickerCalendarBottomSheetDelegate {

    func calendarBottomSheet(_ sheet: DatePickerCalendarBottomSheet, didSelect date: Date) {
        viewModel.send(.selectDate(date))
    }
}

// MARK: - TimeSelectionBottomSheetDelegate

extension FixScheduleViewController: TimeSelectionBottomSheetDelegate {

    func timeSelectionBottomSheet(
        _ sheet: TimeSelectionBottomSheet,
        didConfirmStartTime startTime: TimeIndicatorEntity,
        endTime: TimeIndicatorEntity
    ) {
        viewModel.send(.selectStartTime(startTime))
        viewModel.send(.selectEndTime(endTime))
    }
}
