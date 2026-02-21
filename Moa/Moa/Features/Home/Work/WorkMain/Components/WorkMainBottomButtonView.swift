//
//  WorkMainBottomButtonView.swift
//  Moa
//
//  Created by 정도현 on 2/20/26.
//

import UIKit
import SnapKit

/// 근무 메인 화면 하단 액션 영역
final class WorkMainBottomButtonView: UIView {

    // MARK: - Callbacks

    private var primaryAction: (() -> Void)?
    private var vacationAction: (() -> Void)?

    // MARK: - UI

    private let autoWorkIndicator = SpeechBubble()

    private lazy var primaryButton: AppButton = {
        let button = AppButton()
        button.applyStyle(.primary())
        button.addTarget(self, action: #selector(didTapPrimary), for: .touchUpInside)
        return button
    }()

    private lazy var vacationButton: UnderlineTextButton = {
        let button = UnderlineTextButton(title: "")
        button.addTarget(self, action: #selector(didTapVacation), for: .touchUpInside)
        return button
    }()

    private lazy var stackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [autoWorkIndicator, primaryButton, vacationButton])
        sv.axis      = .vertical
        sv.alignment = .center
        sv.setCustomSpacing(12, after: autoWorkIndicator)
        sv.setCustomSpacing(16, after: primaryButton)
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
        addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.top.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(24)
        }
        primaryButton.snp.makeConstraints {
            $0.leading.trailing.equalTo(self)
        }
    }

    // MARK: - Configure

    func configure(
        status: HomeScheduleStatus,
        autoWorkText: String? = nil,
        primaryAction: (() -> Void)?,
        vacationAction: (() -> Void)? = nil
    ) {
        self.primaryAction  = primaryAction
        self.vacationAction = vacationAction

        primaryButton.setTitle(status.primaryButtonTitle, for: .normal)

        let isBeforeWork = status.showsVacationButton

        autoWorkIndicator.isHidden = !isBeforeWork
        vacationButton.isHidden    = !isBeforeWork

        if isBeforeWork {
            autoWorkIndicator.configure(text: autoWorkText ?? "")
            vacationButton.updateTitle("오늘 휴가예요")
        }
    }

    // MARK: - Actions

    @objc private func didTapPrimary()  { primaryAction?() }
    @objc private func didTapVacation() { vacationAction?() }
}
