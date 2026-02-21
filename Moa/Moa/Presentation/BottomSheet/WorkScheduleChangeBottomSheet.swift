//
//  WorkScheduleChangeBottomSheet.swift
//  Moa
//
//  Created by 정도현 on 2/20/26.
//

import UIKit
import SnapKit

// MARK: - WorkScheduleChangeType

enum WorkScheduleChangeType: CaseIterable {
    case vacation
    case endWork
    case changeSchedule

    var description: String {
        switch self {
        case .vacation:       return "오늘 휴가에요"
        case .endWork:        return "오늘 근무를 마칠 거에요"
        case .changeSchedule: return "근무 시간 조정이 필요해요"
        }
    }
}

// MARK: - Delegate

protocol WorkScheduleChangeBottomSheetDelegate: AnyObject {
    func workScheduleChangeBottomSheet(
        _ sheet: WorkScheduleChangeBottomSheet,
        didConfirm type: WorkScheduleChangeType
    )
    func workScheduleChangeBottomSheetDidCancel(_ sheet: WorkScheduleChangeBottomSheet)
}

// MARK: - WorkScheduleChangeBottomSheet

final class WorkScheduleChangeBottomSheet: UIViewController {

    // MARK: - Properties

    weak var delegate: WorkScheduleChangeBottomSheetDelegate?

    private var selectedType: WorkScheduleChangeType? {
        didSet {
            syncCardStates()
            confirmButton.isEnabled = selectedType != nil
        }
    }

    private var cards: [WorkScheduleChangeCardView] = []

    // MARK: - UI

    private let titleLabel: StyledLabel = {
        let label = StyledLabel()
        label.setText(
            "근무 일정에 변동이 생겼나요?",
            style: .init(typography: AppTypography.t1_700, color: AppColor.IconAndText.highEmphasis)
        )
        return label
    }()

    private let cardStack: UIStackView = {
        let sv = UIStackView()
        sv.axis    = .vertical
        sv.spacing = 8
        return sv
    }()

    private let buttonStack: UIStackView = {
        let sv = UIStackView()
        sv.axis         = .horizontal
        sv.spacing      = 12
        sv.distribution = .fillEqually
        return sv
    }()

    private lazy var cancelButton: AppButton = {
        let button = AppButton()
        button.setTitle("취소", for: .normal)
        button.applyStyle(.tertiary())
        button.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
        return button
    }()

    private lazy var confirmButton: AppButton = {
        let button = AppButton()
        button.setTitle("확인", for: .normal)
        button.applyStyle(.primary())
        button.isEnabled = false
        button.addTarget(self, action: #selector(didTapConfirm), for: .touchUpInside)
        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.Container.primary
        
        setupHierarchy()
        setupConstraints()
        buildCards()
    }

    // MARK: - Layout

    private func setupHierarchy() {
        view.addSubViews([titleLabel, cardStack, buttonStack])
        buttonStack.addArrangedSubview(cancelButton)
        buttonStack.addArrangedSubview(confirmButton)
    }

    private func setupConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
        }
        cardStack.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
        }
        buttonStack.snp.makeConstraints {
            $0.top.equalTo(cardStack.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
            $0.height.equalTo(64)
            $0.bottom.equalToSuperview().inset(24)
        }
    }

    // MARK: - Cards

    private func buildCards() {
        WorkScheduleChangeType.allCases.forEach { type in
            let card = WorkScheduleChangeCardView(type: type)
            card.onTap = { [weak self] tappedType in
                self?.selectedType = (self?.selectedType == tappedType) ? nil : tappedType
            }
            cardStack.addArrangedSubview(card)
            cards.append(card)
        }
    }

    private func syncCardStates() {
        cards.forEach { $0.setSelected($0.scheduleChangeType == selectedType) }
    }

    // MARK: - Actions

    @objc private func didTapCancel() {
        delegate?.workScheduleChangeBottomSheetDidCancel(self)
        dismissBottomSheet()
    }

    @objc private func didTapConfirm() {
        guard let type = selectedType else { return }
        delegate?.workScheduleChangeBottomSheet(self, didConfirm: type)
        dismissBottomSheet()
    }
    
    private func dismissBottomSheet() {
        if let bottomSheet = parent as? BottomSheetViewController {
            bottomSheet.animateDismiss()
        }
    }
}

extension WorkScheduleChangeBottomSheet: BottomSheetPresentable {

}
