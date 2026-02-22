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
    func workEndBottomIndicatorDidTapExtendWork(_ view: WorkEndBottomIndicator)
    /// 근무시간 행 탭 → 실제 근무 시간을 알려주세요 (.changeWorkTime)
    func workEndBottomIndicatorDidTapTimeRow(_ view: WorkEndBottomIndicator)
    func workEndBottomIndicatorDidTapConfirm(_ view: WorkEndBottomIndicator)
}

// MARK: - WorkEndBottomIndicator

final class WorkEndBottomIndicator: UIView {

    // MARK: - Delegate

    weak var delegate: WorkEndBottomIndicatorDelegate?

    // MARK: - UI

    private lazy var summaryView: WorkMainSummaryView = {
        let view = WorkMainSummaryView()
        // onTapTimeRow → WorkEndBottomIndicator delegate 전달
        view.onTapTimeRow = { [weak self] in
            guard let self else { return }
            delegate?.workEndBottomIndicatorDidTapTimeRow(self)
        }
        return view
    }()

    private lazy var extendWorkButton: AppButton = {
        let button = AppButton()
        button.setTitle("더 일할게요", for: .normal)
        button.applyStyle(.tertiary())
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

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Setup

    private func setup() {
        addSubViews([summaryView, buttonStack])

        buttonStack.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
            $0.bottom.equalTo(safeAreaLayoutGuide).inset(24)
            $0.height.equalTo(64)
        }
        summaryView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
            $0.bottom.equalTo(buttonStack.snp.top).offset(-32)
        }
    }

    // MARK: - Configure

    /// 근무완료 1 진입 시 호출
    /// - summaryView: alpha 0.6, 탭 가능 (실제 근무 시간 수정)
    func configure(status: WorkStatus, data: HomeEntity) {
        // configureForEndIndicator: alpha 0.6 + tappable: true 보장
        summaryView.configureForEndIndicator(data: data)
    }

    // MARK: - Actions

    @objc private func didTapExtend()  { delegate?.workEndBottomIndicatorDidTapExtendWork(self) }
    @objc private func didTapConfirm() { delegate?.workEndBottomIndicatorDidTapConfirm(self) }
}
