//
//  TimeSelectionView.swift
//  Moa
//
//  Created by 정도현 on 2/15/26.
//

import UIKit
import SnapKit

// MARK: - Selection Mode
enum TimeSelectionMode {
    case selectingStart
    case selectingEnd
    case completed
}

// MARK: - TimeSelectionViewDelegate
protocol TimeSelectionViewDelegate: AnyObject {
    func timeSelectionView(
        _ view: TimeSelectionView,
        didConfirmStartTime startTime: TimeIndicatorEntity,
        endTime: TimeIndicatorEntity
    )
}

// MARK: - TimeSelectionView
final class TimeSelectionView: UIView {
    
    // MARK: - Properties
    weak var delegate: TimeSelectionViewDelegate?
    
    private var selectedStartTime: TimeIndicatorEntity
    private var selectedEndTime: TimeIndicatorEntity
    private var selectionMode: TimeSelectionMode = .selectingStart
    
    private lazy var startTimeButton: TimeDisplayView = {
        let button = TimeDisplayView(timeCase: .start)
        button.addTarget(self, action: #selector(startTimeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(resource: .Icon.iconArrowRight)
        return imageView
    }()
    
    private lazy var endTimeButton: TimeDisplayView = {
        let button = TimeDisplayView(timeCase: .end)
        button.addTarget(self, action: #selector(endTimeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var timeDisplayStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [startTimeButton, arrowImageView, endTimeButton])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fill
        
        return stack
    }()
    
    // Wheel Picker
    private var wheelPicker: TimeWheelPickerView!
    
    private lazy var confirmButton: AppButton = {
        let button = AppButton()
        button.setTitle("확인", for: .normal)
        button.applyStyle(.primary())
        button.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Initialization
    init(startTime: TimeIndicatorEntity = .from(hour: 9, minute: 20),
         endTime: TimeIndicatorEntity = .from(hour: 18, minute: 0)) {
        self.selectedStartTime = startTime
        self.selectedEndTime = endTime
        
        super.init(frame: .zero)
        
        wheelPicker = TimeWheelPickerView(
            initialHour: startTime.hour,
            initialMinute: startTime.minute
        )
        wheelPicker.delegate = self
        
        setupViews()
        updateTimeDisplay()
        updateSelectionState()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupViews() {
        
        backgroundColor = AppColor.Container.primary
        
        // Time Display Container
        addSubview(timeDisplayStackView)
        timeDisplayStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
            make.height.equalTo(55)
        }
        
        arrowImageView.snp.makeConstraints { make in
            make.width.height.equalTo(24)
        }
        
        startTimeButton.snp.makeConstraints {
            $0.width.equalTo(endTimeButton)
        }
        
        // Wheel Picker
        addSubview(wheelPicker)
        wheelPicker.snp.makeConstraints { make in
            make.top.equalTo(timeDisplayStackView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
        }
        
        // Confirm Button
        addSubview(confirmButton)
        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(wheelPicker.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
            make.height.equalTo(64)
            make.bottom.lessThanOrEqualToSuperview().inset(24)
        }
    }
    
    // MARK: - Actions
    @objc private func startTimeButtonTapped() {
        
        selectionMode = .selectingStart
        updateSelectionState()
        
        wheelPicker.setTime(
            hour: selectedStartTime.hour,
            minute: selectedStartTime.minute,
            animated: true
        )
    }
    
    @objc private func endTimeButtonTapped() {
        selectionMode = .selectingEnd
        updateSelectionState()
        
        wheelPicker.setTime(
            hour: selectedEndTime.hour,
            minute: selectedEndTime.minute,
            animated: true
        )
    }
    
    @objc private func confirmButtonTapped() {
        switch selectionMode {
        case .selectingStart:
            selectionMode = .selectingEnd
            updateSelectionState()
            
            wheelPicker.setTime(
                hour: selectedEndTime.hour,
                minute: selectedEndTime.minute,
                animated: true
            )
            
        case .selectingEnd:
            // TODO: 출근 시간이 퇴근 시간보다 늦게 입력 한 경우 처리 필요!
            if selectedStartTime.hour > selectedEndTime.hour ||
                (selectedStartTime.hour == selectedEndTime.hour && selectedStartTime.minute > selectedEndTime.minute) {
                
            }
            
            // 완료 상태
            selectionMode = .completed
            updateSelectionState()
            
            // Delegate 호출
            delegate?.timeSelectionView(self, didConfirmStartTime: selectedStartTime, endTime: selectedEndTime)
            
        case .completed:
            delegate?.timeSelectionView(self, didConfirmStartTime: selectedStartTime, endTime: selectedEndTime)
        }
    }
    
    // MARK: - Private Methods
    private func updateTimeDisplay() {
        startTimeButton.setTime(selectedStartTime)
        endTimeButton.setTime(selectedEndTime)
    }
    
    private func updateSelectionState() {
        // 선택 모드에 따라 활성화 상태 변경
        switch selectionMode {
        case .selectingStart:
            startTimeButton.setActive(true)
            endTimeButton.setActive(false)
            
        case .selectingEnd, .completed:
            startTimeButton.setActive(true)
            endTimeButton.setActive(true)
        }
    }
}

// MARK: - TimeWheelPickerViewDelegate
extension TimeSelectionView: TimeWheelPickerViewDelegate {
    func timeWheelPickerDidChange(_ picker: TimeWheelPickerView, time: TimeIndicatorEntity) {
        switch selectionMode {
        case .selectingStart:
            if selectedStartTime != time {
                selectedStartTime = time
                startTimeButton.setTime(time)
            }
            
        case .selectingEnd:
            if selectedEndTime != time {
                selectedEndTime = time
                endTimeButton.setTime(time)
            }
            
        case .completed:
            break
        }
    }
}
