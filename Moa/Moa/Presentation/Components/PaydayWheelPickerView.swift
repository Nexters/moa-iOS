//
//  PaydayWheelPickerView.swift
//  Moa
//
//  Created by mirim on 2/22/26.
//

import UIKit
import SnapKit

// MARK: - PaydayWheelPickerViewDelegate

protocol PaydayWheelPickerViewDelegate: AnyObject {
    func paydayWheelDidChange(_ view: PaydayWheelPickerView, payday: Int)
}

// MARK: - PaydayWheelPickerView

final class PaydayWheelPickerView: UIView {
    
    // MARK: - Constants
    
    private enum Constants {
        static let range = 1...28
        static let cellHeight: CGFloat = 44
        static let visibleRowCount: CGFloat = 5
    }
    
    // MARK: - Properties
    weak var delegate: PaydayWheelPickerViewDelegate?
    
    private let selectedPayday: Int
    private var currentPayday: Int
    private var hasAppliedInitialScroll = false
    private var pickerHeight: CGFloat {
        Constants.cellHeight * Constants.visibleRowCount
    }
    
    // MARK: UI Components
    
    private let backgroundContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColor.Container.secondary
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let selectionHighlightView: UIView = {
        let v = UIView()
        v.backgroundColor = AppColor.Container.primary
        v.layer.cornerRadius = 12
        return v
    }()
    
    private lazy var paydayColumn: TimeWheelColumnView = {
        let column = TimeWheelColumnView(
            values: Constants.range.map { String(format: "%d일", $0) },
            initialIndex: max(0, selectedPayday - 1)
        )
        
        column.onValueChanged = { [weak self] in
            guard let self = self else { return }
            let index = self.paydayColumn.selectedIndex
            self.currentPayday = index + Constants.range.lowerBound
            self.notifyDelegate()
        }
        
        return column
    }()
    
    // MARK: - Init
    
    init(selectedPayday: Int) {
        self.selectedPayday = selectedPayday
        self.currentPayday = selectedPayday
        super.init(frame: .zero)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard !hasAppliedInitialScroll, bounds.width > 0 else { return }
        hasAppliedInitialScroll = true
        
        paydayColumn.layoutIfNeeded()
        setPayday(to: selectedPayday)
    }
    
    // MARK: - Public Methods
    
    func setPayday(to payday: Int) {
        let index = max(0, payday - 1)
        paydayColumn.scrollToIndexSilently(index, animated: true)
        currentPayday = payday
    }
    
    // MARK: - Private Methods
    
    private func notifyDelegate() {
        delegate?.paydayWheelDidChange(self, payday: currentPayday)
    }
    
    private func setupLayout() {
        addSubview(backgroundContainerView)
        backgroundContainerView.addSubview(selectionHighlightView)
        backgroundContainerView.addSubview(paydayColumn)
        
        backgroundContainerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        paydayColumn.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
            make.height.equalTo(pickerHeight)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        selectionHighlightView.snp.makeConstraints { make in
            make.centerY.equalTo(paydayColumn.snp.centerY)
            make.leading.trailing.equalTo(paydayColumn)
            make.height.equalTo(52)
        }
    }
}

