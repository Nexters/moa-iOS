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
        return label
    }()

    private lazy var hintRow: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [hintIconView, hintLabel])
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .center
        stack.isHidden = true
        return stack
    }()

    private lazy var headerStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, hintRow])
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
        return stack
    }()

    private lazy var paydaySelectionView: PaydaySelectionView = {
        let view = PaydaySelectionView(initialPayday: initialPayday)
        view.delegate = self
        return view
    }()
    
    private lazy var confirmButton: AppButton = {
        let btn = AppButton()
        btn.setTitle("확인", for: .normal)
        btn.applyStyle(.primary())
        btn.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let contentView = UIView()
        contentView.backgroundColor = .clear
        view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentView.addSubview(headerStack)
        headerStack.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
        }

        contentView.addSubview(confirmButton)
        confirmButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
            make.bottom.equalToSuperview().inset(24)
            make.height.equalTo(64)
        }

        contentView.addSubview(paydaySelectionView)
        paydaySelectionView.snp.makeConstraints { make in
            make.top.equalTo(headerStack.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
            make.bottom.equalTo(confirmButton.snp.top).offset(-20)
        }

        view.layoutIfNeeded()
    }
    
    // MARK: - Init
    
    init(initialPayday: Int) {
        self.initialPayday = initialPayday
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        switch payday {
        case 29, 30:
            hintLabel.setText(
                "해당 날짜가 없는 달에는 말일이 월급일로 설정돼요",
                style: .init(typography: AppTypography.b2_500, color: AppColor.IconAndText.green)
            )
            hintRow.isHidden = false
        case 31:
            hintLabel.setText(
                "매 달 말일을 월급일로 설정할게요",
                style: .init(typography: AppTypography.b2_500, color: AppColor.IconAndText.green)
            )
            hintRow.isHidden = false
        default:
            hintRow.isHidden = true
        }
    }
}
