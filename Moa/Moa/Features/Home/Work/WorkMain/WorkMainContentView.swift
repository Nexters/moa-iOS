//
//  WorkMainContentView.swift
//  Moa
//
//  Created by 정도현 on 2/18/26.
//

import UIKit
import SnapKit

// MARK: - Delegate

protocol WorkMainContentViewDelegate: AnyObject {
    func workMainContentViewDidTapPrimaryAction(_ view: WorkMainContentView)
    func workMainContentViewDidTapVacation(_ view: WorkMainContentView)
    func workMainContentViewDidRequestTimeSelection(_ view: WorkMainContentView)
    func workMainContentViewDidTapWorkHistory(_ view: WorkMainContentView)
}

// MARK: - WorkMainContentView

final class WorkMainContentView: UIView {

    // MARK: - Delegate

    weak var delegate: WorkMainContentViewDelegate?

    // MARK: - UI

    private lazy var headerView: WorkMainHeaderView = {
        let view = WorkMainHeaderView()
        view.delegate = self
        return view
    }()

    private let bottomButtonView = WorkMainBottomButtonView()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Setup

    private func setup() {
        backgroundColor = AppColor.Background.primary

        addSubViews([headerView, bottomButtonView])

        headerView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(20)
            $0.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
        }

        bottomButtonView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
            $0.bottom.equalTo(safeAreaLayoutGuide)
        }
    }

    // MARK: - Configure

    /// ViewModel이 내려준 HomeDisplayData를 그대로 받아 하위 뷰로 전달합니다.
    func configure(with display: HomeDisplayData) {
        headerView.configure(with: display)

        bottomButtonView.configure(
            status:        display.scheduleStatus,
            autoWorkText:  autoWorkText(for: display),
            primaryAction: { [weak self] in
                guard let self else { return }
                switch display.scheduleStatus {
                case .afterWork, .onVacation:
                    // "이번달 근무 기록 확인하기" → 캘린더 이동
                    delegate?.workMainContentViewDidTapWorkHistory(self)
                default:
                    delegate?.workMainContentViewDidTapPrimaryAction(self)
                }
            },
            vacationAction: { [weak self] in
                guard let self else { return }
                delegate?.workMainContentViewDidTapVacation(self)
            }
        )
    }

    // MARK: - Helpers

    private func autoWorkText(for display: HomeDisplayData) -> String? {
        guard display.scheduleStatus == .beforeWork else { return nil }
        return "\(display.scheduledClockIn.displayString)에 자동 출근 예정이에요"
    }
}

// MARK: - WorkMainHeaderViewDelegate

extension WorkMainContentView: WorkMainHeaderViewDelegate {
    func workMainHeaderViewDidTapTimeRow(_ view: WorkMainHeaderView) {
        delegate?.workMainContentViewDidRequestTimeSelection(self)
    }
}
