//
//  TimeWheelPickerView.swift
//  Moa
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
    private let minuteUnit: Int = 5
    
    private var pickerHeight: CGFloat {
        cellHeight * visibleRowCount
    }
    
    // MARK: - Properties
    
    private let initialHour: Int
    private let initialMinute: Int
    
    /// 0, 5, 10, 15 ... 55
    private let minuteValues = stride(from: 0, through: 55, by: 5).map { $0 }
    
    // MARK: - Background Container
    
    private let backgroundContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColor.Container.secondary
        view.layer.cornerRadius = 16
        return view
    }()
    
    // MARK: - Columns
    
    private lazy var hourColumn: TimeWheelColumnView = {
        let column = TimeWheelColumnView(
            values: (0...23).map { String(format: "%d시", $0) },
            initialIndex: initialHour,
            alignment: .right
        )
        
        column.onValueChanged = { [weak self] in
            self?.notifyDelegate()
        }
        
        return column
    }()
    
    private lazy var minuteColumn: TimeWheelColumnView = {
        let column = TimeWheelColumnView(
            values: minuteValues.map { "\($0)분" },
            initialIndex: minuteIndex(from: initialMinute),
            alignment: .left
        )
        
        column.onValueChanged = { [weak self] in
            self?.notifyDelegate()
        }
        
        return column
    }()
    
    // MARK: - Selection Highlight
    
    private let selectionView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.backgroundColor = AppColor.Container.primary
        return view
    }()
    
    // MARK: - Init
    
    init(initialHour: Int, initialMinute: Int) {
        self.initialHour = initialHour
        self.initialMinute = initialMinute
        super.init(frame: .zero)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Public Methods
    
    var selectedTime: TimeIndicatorEntity {
        TimeIndicatorEntity.from(
            hour: hourColumn.selectedIndex,
            minute: selectedMinuteValue
        )
    }
    
    func setTime(hour: Int, minute: Int, animated: Bool = false) {
        hourColumn.scrollToIndexSilently(hour, animated: animated)
        
        let minuteIndex = minuteIndex(from: minute)
        minuteColumn.scrollToIndexSilently(minuteIndex, animated: animated)
    }
    
    // MARK: - Private Methods
    
    private var selectedMinuteValue: Int {
        minuteValues[minuteColumn.selectedIndex]
    }
    
    private func minuteIndex(from minute: Int) -> Int {
        let roundedMinute = (minute / minuteUnit) * minuteUnit
        return minuteValues.firstIndex(of: roundedMinute) ?? 0
    }
    
    private func notifyDelegate() {
        delegate?.timeWheelPickerDidChange(self, time: selectedTime)
    }
}

// MARK: - Layout

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
