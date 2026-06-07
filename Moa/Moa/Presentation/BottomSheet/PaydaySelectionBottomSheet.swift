//
//  PaydaySelectionBottomSheet.swift
//  Moa
//
//  Created by mirim on 2/22/26.
//

import UIKit
import SnapKit

// MARK: - PaydaySelectionBottomSheetDelegate

protocol PaydaySelectionBottomSheetDelegate: AnyObject {
    func paydaySelectionBottomSheet(
        _ sheet: PaydaySelectionBottomSheet,
        didTapConfirmButton selectedPayday: Int
    )
}

// MARK: - PaydaySelectionBottomSheet

final class PaydaySelectionBottomSheet: UIViewController {
    
    // MARK: - Properties
    
    weak var delegate: PaydaySelectionBottomSheetDelegate?
    private let initialPayday: Int
    
    // MARK: - UI Components
    
    private let titleLabel: StyledLabel = {
        let label = StyledLabel()
        label.setText(
            "월급일을 선택해주세요",
            style: .init(
                typography: AppTypography.t1_700,
                color: AppColor.IconAndText.highEmphasis
            )
        )
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()

    private let hintIconView: UIImageView = {
        let iv = UIImageView(image: UIImage(resource: .Icon.iconInfo))
        iv.contentMode = .scaleAspectFit
        iv.snp.makeConstraints { make in
            make.size.equalTo(16)
        }
        return iv
    }()

    private let hintLabel: StyledLabel = {
        let label = StyledLabel()
        label.numberOfLines = 0
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()

    private lazy var hintRow: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [hintIconView, hintLabel])
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .center
        stack.isHidden = true
        stack.setContentHuggingPriority(.required, for: .vertical)
        return stack
    }()

    private lazy var headerStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, hintRow])
        stack.axis = .vertical
        stack.spacing = -8.5
        stack.alignment = .leading
        stack.setContentHuggingPriority(.required, for: .vertical)
        return stack
    }()

    private lazy var paydaySelectionView: PaydaySelectionView = {
        let view = PaydaySelectionView(initialPayday: initialPayday)
        view.delegate = self
        view.setContentHuggingPriority(.required, for: .vertical)
        return view
    }()
    
    private lazy var confirmButton: AppButton = {
        let btn = AppButton()
        btn.setTitle("확인", for: .normal)
        btn.applyStyle(.primary())
        btn.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        btn.setContentHuggingPriority(.required, for: .vertical)
        return btn
    }()

    private lazy var mainStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [headerStack, paydaySelectionView, confirmButton])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 0
        return stack
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(mainStackView)
        mainStackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
            make.bottom.equalToSuperview().inset(24)
        }

        mainStackView.setCustomSpacing(16, after: headerStack)
        mainStackView.setCustomSpacing(20, after: paydaySelectionView)

        confirmButton.snp.makeConstraints { make in
            make.height.equalTo(64)
        }

        view.layoutIfNeeded()
        updateHintRow(for: initialPayday)
    }

    // MARK: - Init
    
    init(initialPayday: Int) {
        self.initialPayday = initialPayday
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func updateHintRow(for payday: Int) {
        let shouldHide: Bool
        switch payday {
        case 29, 30:
            hintLabel.setText(
                "해당 날짜가 없는 달에는 말일이 월급일로 설정돼요",
                style: .init(typography: AppTypography.b2_500, color: AppColor.IconAndText.green)
            )
            shouldHide = false
        case 31:
            hintLabel.setText(
                "매 달 말일을 월급일로 설정할게요",
                style: .init(typography: AppTypography.b2_500, color: AppColor.IconAndText.green)
            )
            shouldHide = false
        default:
            shouldHide = true
        }

        hintRow.isHidden = shouldHide
        
        // 힌트가 있을 때는 이미 paydaySelectionView 내부에 16px 여백이 있으므로 
        // mainStackView의 여백을 0으로 줄여 중첩을 방지
        mainStackView.setCustomSpacing(shouldHide ? 16 : 0, after: headerStack)
        
        mainStackView.layoutIfNeeded()
        view.layoutIfNeeded()
        
        if let bottomSheet = parent as? BottomSheetViewController {
            bottomSheet.view.setNeedsLayout()
            UIView.animate(withDuration: 0.25) {
                bottomSheet.view.layoutIfNeeded()
            }
        }
    }

    @objc private func confirmButtonTapped() {
        let selected = paydaySelectionView.selectedPayday
        delegate?.paydaySelectionBottomSheet(self, didTapConfirmButton: selected)
        
        if let bottomSheet = parent as? BottomSheetViewController {
            bottomSheet.animateDismiss()
        }
    }
}

extension PaydaySelectionBottomSheet: BottomSheetPresentable {
    
}

extension PaydaySelectionBottomSheet: PaydaySelectionViewDelegate {
    func paydaySelectionView(_ picker: PaydaySelectionView, didConfirmPayday payday: Int) {
        delegate?.paydaySelectionBottomSheet(self, didTapConfirmButton: payday)
    }

    func paydaySelectionView(_ picker: PaydaySelectionView, didUpdatePayday payday: Int) {
        updateHintRow(for: payday)
    }
}
