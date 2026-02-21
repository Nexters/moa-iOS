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
        case .add:
            return "추가"
        case .fix:
            return "수정"
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
        view.onTap = { [weak self] in self?.presentDatePicker() }
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
        btn.applyStyle(.secondary())
        btn.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
        return btn
    }()

    private lazy var confirmButton: AppButton = {
        let btn = AppButton()
        btn.setTitle(viewModel.viewType.title, for: .normal)
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

        // 초기 시간 표시
        let s = viewModel.state
        workingTimeRangeRowView.configure(
            start: s.startTime.displayString,
            end:   s.endTime.displayString
        )
    }

    override func bind() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.render($0) }
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
        // 타이틀
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            $0.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
        }

        // ── 날짜 구간 ──────────────────────────
        dateSectionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
        }
        dateRangeCardView.snp.makeConstraints {
            $0.top.equalTo(dateSectionLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
            $0.height.equalTo(60)
        }

        // ── 일정 타입 ──────────────────────────
        scheduleTypeOptionView.snp.makeConstraints {
            $0.top.equalTo(dateRangeCardView.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
        }

        // ── 근무 시간 ──────────────────────────
        workingHourSection.snp.makeConstraints {
            $0.top.equalTo(scheduleTypeOptionView.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
        }

        // ── 하단 버튼 ──────────────────────────
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
        // 날짜 카드
        dateRangeCardView.configure(dateRange: state.dateRange)

        // 일정 타입 (notify: false → 무한루프 방지)
        scheduleTypeOptionView.setSelected(state.scheduleType)

        // 근무 시간 — TimeRangeRowView.configure(start:end:)
        workingTimeRangeRowView.configure(
            start: state.startTime.displayString,
            end:   state.endTime.displayString
        )

        // 확인 버튼 활성 여부
        confirmButton.isEnabled = state.isConfirmEnabled
    }
}

// MARK: - Bottom Sheet Presentation

private extension FixScheduleViewController {

    func presentDatePicker() {
        let sheet = DatePickerCalendarBottomSheet()
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

    /// BaseViewController의 replaceSystemBackButtonWithAppBackButton이 호출하는 타겟
    @objc func didTapBack() {
        coordinatorDelegate?.fixScheduleViewControllerDidCancel(self)
    }

    @objc private func didTapCancel() {
        coordinatorDelegate?.fixScheduleViewControllerDidCancel(self)
    }

    @objc private func didTapConfirm() {
        viewModel.send(.confirmTapped)
        coordinatorDelegate?.fixScheduleViewControllerDidConfirm(self, state: viewModel.state)
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
