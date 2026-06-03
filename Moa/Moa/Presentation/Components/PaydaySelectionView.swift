//
//  PaydayWheelPickerView.swift
//  Moa
//
//  Created by mirim on 2/22/26.
//

import UIKit
import SnapKit

// MARK: - PaydaySelectionViewDelegate

protocol PaydaySelectionViewDelegate: AnyObject {
    func paydaySelectionView(
        _ picker: PaydaySelectionView,
        didUpdatePayday payday: Int
    )
    func paydaySelectionView(
        _ picker: PaydaySelectionView,
        didConfirmPayday payday: Int
    )
}

// MARK: - PaydaySelectionView

final class PaydaySelectionView: UIView {
    
    // MARK: - Constants
    
    private enum Constants {
        static let range = 1...31
        static let cellHeight: CGFloat = 44
        static let visibleRowCount: CGFloat = 5
    }
    
    // MARK: - Properties
    weak var delegate: PaydaySelectionViewDelegate?
    private(set) var selectedPayday: Int
    
    // MARK: UI Components
    
    private var wheelPicker: PaydayWheelPickerView!
    
    // MARK: - Init
    
    init(initialPayday: Int) {
        self.selectedPayday = initialPayday
        wheelPicker = PaydayWheelPickerView(
            selectedPayday: initialPayday
        )
        
        super.init(frame: .zero)
        wheelPicker.delegate = self
        setupViews()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        wheelPicker.setPayday(to: selectedPayday)
        
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        backgroundColor = AppColor.Container.secondary
        layer.cornerRadius = 16
        
        addSubview(wheelPicker)
        
        let pickerHeight: CGFloat = 44 * 5
        wheelPicker.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
            make.height.equalTo(pickerHeight)
            make.bottom.equalToSuperview().inset(16)
        }
    }
}

extension PaydaySelectionView: PaydayWheelPickerViewDelegate {
    func paydayWheelDidChange(_ picker: PaydayWheelPickerView, payday: Int) {
        selectedPayday = payday
        delegate?.paydaySelectionView(self, didUpdatePayday: payday)
    }
}
