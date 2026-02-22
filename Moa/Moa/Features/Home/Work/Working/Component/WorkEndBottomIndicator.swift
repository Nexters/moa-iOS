//
//  WorkEndBottomIndicator.swift
//  Moa
//
//  Created by 정도현 on 2/22/26.
//

import UIKit
import SnapKit

// MARK: - WorkEndBottomIndicatorDelegate

protocol WorkEndBottomIndicatorDelegate: AnyObject {
    /// "더 일할게요" 탭 → 퇴근 시간 연장 시트
    func workEndBottomIndicatorDidTapExtendWork(_ view: WorkEndBottomIndicator)
    /// 근무시간 행 탭 → 출퇴근 수정 시트
    func workEndBottomIndicatorDidTapTimeRow(_ view: WorkEndBottomIndicator)
    /// "완료" 탭 → 근무 완료 화면(캘린더)으로 이동
    func workEndBottomIndicatorDidTapConfirm(_ view: WorkEndBottomIndicator)
}

// MARK: - WorkEndBottomIndicator

final class WorkEndBottomIndicator: UIView {

    // MARK: - Delegate

    weak var delegate: WorkEndBottomIndicatorDelegate?

    // MARK: - UI

    /// 일당 + 근무시간 요약 카드 (finished 전용: chevron X, 탭 → 시간 수정)
    private lazy var summaryView: WorkMainSummaryView = {
        let view = WorkMainSummaryView()
        view.onTapTimeRow = { [weak self] in
            guard let self else { return }
            delegate?.workEndBottomIndicatorDidTapTimeRow(self)
        }
        return view
    }()

    private lazy var extendWorkButton: AppButton = {
        let button = AppButton()
        button.setTitle("더 일할게요", for: .normal)
        button.applyStyle(.secondary())
        button.addTarget(self, action: #selector(didTapExtend), for: .touchUpInside)
        return button
    }()

    private lazy var confirmButton: AppButton = {
        let button = AppButton()
        button.setTitle("완료", for: .normal)
        button.applyStyle(.primary())
        button.addTarget(self, action: #selector(didTapConfirm), for: .touchUpInside)
        return button
    }()

    private lazy var buttonStack: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [extendWorkButton, confirmButton])
        sv.axis         = .horizontal
        sv.spacing      = 12
        sv.distribution = .fillEqually
        return sv
    }()

    // 그라데이션 레이어 (EarningsStackView 위를 자연스럽게 가림)
    private let gradientLayer = CAGradientLayer()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }

    // MARK: - Setup

    private func setup() {
        // 그라데이션: 상단 투명 → 하단 배경색 (불투명)
        gradientLayer.colors = [
            AppColor.Background.primary.withAlphaComponent(0).cgColor,
            AppColor.Background.primary.withAlphaComponent(0.85).cgColor,
            AppColor.Background.primary.cgColor,
        ]
        gradientLayer.locations = [0.0, 0.25, 0.5]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint   = CGPoint(x: 0.5, y: 1)
        layer.insertSublayer(gradientLayer, at: 0)

        addSubViews([summaryView, buttonStack])

        // 버튼 하단 고정
        buttonStack.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
            $0.bottom.equalTo(safeAreaLayoutGuide).inset(24)
            $0.height.equalTo(52)
        }

        // 요약 카드: 버튼 위 20pt
        summaryView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
            $0.bottom.equalTo(buttonStack.snp.top).offset(-20)
        }
    }

    // MARK: - Configure

    /// finished 상태 진입 시 호출
    func configure(status: WorkStatus, data: HomeEntity) {
        // summaryView는 finished 전용 렌더링 사용
        // (finishedTimeRowView: chevron X, onTapTimeRow는 delegate로 연결)
        summaryView.configure(status: status, data: data)
    }

    // MARK: - Actions

    @objc private func didTapExtend()  { delegate?.workEndBottomIndicatorDidTapExtendWork(self) }
    @objc private func didTapConfirm() { delegate?.workEndBottomIndicatorDidTapConfirm(self) }
}
