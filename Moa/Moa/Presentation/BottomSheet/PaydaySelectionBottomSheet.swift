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

        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
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
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
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
        
    }
}
