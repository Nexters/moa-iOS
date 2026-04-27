//
//  WorkMainContentView.swift
//  Moa
//
//  idle: 출근 버튼, 자동출근 말풍선, 휴가 버튼
//  finished(최종완료): 헤더 + "이번달 근무 기록 확인하기" 버튼

import UIKit
import SnapKit

// MARK: - Delegate

protocol WorkMainContentViewDelegate: AnyObject {
    func workMainContentViewDidTapPrimaryAction(_ view: WorkMainContentView)
    func workMainContentViewDidTapVacation(_ view: WorkMainContentView)
    func workMainContentViewDidRequestTimeSelection(_ view: WorkMainContentView)
    /// 최종완료: "이번달 근무 기록 확인하기" 탭 → 캘린더(History) 화면
    func workMainContentViewDidTapWorkHistory(_ view: WorkMainContentView)
}

// MARK: - WorkMainContentView

final class WorkMainContentView: UIView {

    weak var delegate: WorkMainContentViewDelegate?

    // MARK: - UI

    private lazy var headerView: WorkMainHeaderView = {
        let view = WorkMainHeaderView()
        view.delegate = self
        return view
    }()

    /// idle 전용 하단 버튼 영역 (자동출근 말풍선 + 출근 버튼 + 휴가 버튼)
    private let bottomButtonView = WorkMainBottomButtonView()

    /// 최종완료 전용 하단 버튼
    private lazy var workHistoryButton: AppButton = {
        let button = AppButton()
        button.setTitle("이번달 근무 기록 확인하기", for: .normal)
        button.applyStyle(.primary())
        button.addTarget(self, action: #selector(didTapWorkHistory), for: .touchUpInside)
        return button
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Setup

    private func setup() {
        backgroundColor = AppColor.Background.primary

        addSubViews([headerView, bottomButtonView, workHistoryButton])

        headerView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(20)
            $0.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
        }
        bottomButtonView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
            $0.bottom.equalTo(safeAreaLayoutGuide)
        }
        workHistoryButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
            $0.bottom.equalTo(safeAreaLayoutGuide).inset(24)
            $0.height.equalTo(64)
        }
    }

    // MARK: - Configure

    func configure(data: HomeEntity, status: WorkStatusEntity) {
        headerView.configure(data: data, status: status)

        let isFinished = (status == .finished && data.type == .work)

        // 최종완료: "이번달 근무 기록 확인하기" 버튼만 표시
        workHistoryButton.isHidden = !isFinished
        bottomButtonView.isHidden  = isFinished

        if !isFinished {
            bottomButtonView.configure(
                status: status,
                data:   data,
                primaryAction: { [weak self] in
                    guard let self else { return }
                    self.delegate?.workMainContentViewDidTapPrimaryAction(self)
                },
                vacationAction: { [weak self] in
                    guard let self else { return }
                    self.delegate?.workMainContentViewDidTapVacation(self)
                }
            )
        }
    }

    // MARK: - Actions

    @objc private func didTapWorkHistory() {
        delegate?.workMainContentViewDidTapWorkHistory(self)
    }
}

// MARK: - WorkMainHeaderViewDelegate

extension WorkMainContentView: WorkMainHeaderViewDelegate {
    func workMainHeaderViewDidTapTimeRow(_ view: WorkMainHeaderView) {
        // 최종완료(finished) 상태에서는 WorkMainSummaryView의 finishedTimeRowView.onTap = nil
        // 이므로 이 콜백은 idle 상태에서만 실질적으로 호출됨
        delegate?.workMainContentViewDidRequestTimeSelection(self)
    }
}
