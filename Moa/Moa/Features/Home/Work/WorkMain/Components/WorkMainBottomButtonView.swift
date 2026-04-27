//
//  WorkMainBottomButtonView.swift
//  Moa
//
//  idle 상태 전용 하단 버튼 영역
//  finished 상태의 버튼은 WorkEndBottomIndicator에서 처리
//

import UIKit
import SnapKit

final class WorkMainBottomButtonView: UIView {

    // MARK: - Callbacks

    private var primaryAction:  (() -> Void)?
    private var vacationAction: (() -> Void)?

    // MARK: - UI

    private let autoWorkIndicator = SpeechBubble()

    private lazy var primaryButton: AppButton = {
        let button = AppButton()
        button.applyStyle(.primary())
        button.addTarget(self, action: #selector(didTapPrimary), for: .touchUpInside)
        return button
    }()

    private lazy var stackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [autoWorkIndicator, primaryButton])
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

    // MARK: - Configure (idle 상태 전용)

    func configure(
        status:         WorkStatusEntity,
        data:           HomeEntity,
        primaryAction:  (() -> Void)?,
        vacationAction: (() -> Void)? = nil
    ) {
        self.primaryAction  = primaryAction
        self.vacationAction = vacationAction

        autoWorkIndicator.isHidden = (status != .idle)

        primaryButton.setTitle(data.type.bottomButtonText, for: .normal)
        primaryButton.applyStyle(data.type == .work ? .primary() : .tertiary())

        if status == .idle {
            guard let bubbleLabelText = data.type.bubbleLabelText else {
                autoWorkIndicator.isHidden = true
                return
            }

            autoWorkIndicator.isHidden = false

            let bubbleText: String = {
                guard data.type != .none,
                      let clockIn = data.clockInTime else {
                    return bubbleLabelText
                }
                return "\(clockIn.displayString) \(bubbleLabelText)"
            }()

            autoWorkIndicator.configure(text: bubbleText)
        } else {
            autoWorkIndicator.isHidden = true
        }
    }

    // MARK: - Actions

    @objc private func didTapPrimary()  { primaryAction?() }
    @objc private func didTapVacation() { vacationAction?() }
}
