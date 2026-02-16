//
//  TimeWheelPickerView.swift
//  Moa
//
//  Created by 정도현 on 2/15/26.
//

import UIKit
import SnapKit

// MARK: - TimeWheelPickerViewDelegate
protocol TimeWheelPickerViewDelegate: AnyObject {
    func timeWheelPickerDidChange(_ picker: TimeWheelPickerView, time: TimeIndicatorEntity)
}

// MARK: - TimeWheelPickerView
final class TimeWheelPickerView: UIView {
    
    // MARK: - Delegate
    weak var delegate: TimeWheelPickerViewDelegate?
    
    // MARK: - Constants
    private let cellHeight: CGFloat = 44
    private let visibleRowCount: CGFloat = 5
    
    private var pickerHeight: CGFloat {
        cellHeight * visibleRowCount
    }
    
    // MARK: - Background Container
    private let backgroundContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColor.Container.secondary
        view.layer.cornerRadius = 16
        return view
    }()
    
    // MARK: - Columns
    private var hourColumn: TimeWheelColumnView!
    private var minuteColumn: TimeWheelColumnView!
    
    // MARK: - Selection Highlight
    private let selectionView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.backgroundColor = AppColor.Container.primary
        return view
    }()
    
    // MARK: - Init
    init(initialHour: Int = 9, initialMinute: Int = 0) {
        super.init(frame: .zero)
        
        hourColumn = TimeWheelColumnView(
            values: (0...23).map { String(format: "%d시", $0) },
            initialIndex: initialHour,
            alignment: .right
        )
        hourColumn.onValueChanged = { [weak self] in
            self?.notifyDelegate()
        }
        
        minuteColumn = TimeWheelColumnView(
            values: (0...59).map { String(format: "%d분", $0) },
            initialIndex: initialMinute,
            alignment: .left
        )
        minuteColumn.onValueChanged = { [weak self] in
            self?.notifyDelegate()
        }
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Public Methods
    var selectedTime: TimeIndicatorEntity {
        TimeIndicatorEntity.from(
            hour: hourColumn.selectedIndex,
            minute: minuteColumn.selectedIndex
        )
    }
    
    func setTime(hour: Int, minute: Int, animated: Bool = false) {
        hourColumn.scrollToIndexSilently(hour, animated: animated)
        minuteColumn.scrollToIndexSilently(minute, animated: animated)
    }
    
    // MARK: - Private Methods
    private func notifyDelegate() {
        delegate?.timeWheelPickerDidChange(self, time: selectedTime)
    }
}

private extension TimeWheelPickerView {
    
    func setupLayout() {
        addSubview(backgroundContainerView)
        backgroundContainerView.addSubview(selectionView)
        backgroundContainerView.addSubview(hourColumn)
        backgroundContainerView.addSubview(minuteColumn)
        
        backgroundContainerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(pickerHeight)
        }
        
        hourColumn.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.5)
        }
        
        minuteColumn.snp.makeConstraints {
            $0.trailing.top.bottom.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.5)
        }
        
        selectionView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(8)
            $0.height.equalTo(52)
        }
    }
}
