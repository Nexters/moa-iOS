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
    /// optionButton 탭 (예: "오늘 휴가") — 필요 없는 케이스는 구현 불필요
    func timeSelectionViewDidTapOption(_ view: TimeSelectionView)
}

// default 구현: option 탭은 선택사항
extension TimeSelectionViewDelegate {
    func timeSelectionViewDidTapOption(_ view: TimeSelectionView) {}
}

// MARK: - TimeSelectionView
final class TimeSelectionView: UIView {
    
    // MARK: - Properties
    weak var delegate: TimeSelectionViewDelegate?
    
    private var selectedStartTime: TimeIndicatorEntity
    private var selectedEndTime:   TimeIndicatorEntity
    private var selectionMode: TimeSelectionMode = .selectingStart
    
    /// true이면 출근 버튼 탭 불가 (퇴근 시간만 수정 모드)
    private let isEndTimeOnly: Bool
    
    // MARK: - UI
    private let durationView = WorkDurationView()
    
    private lazy var startTimeButton: TimeDisplayView = {
        let button = TimeDisplayView(timeCase: .start)
        button.addTarget(self, action: #selector(startTimeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let arrowImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(resource: .Icon.iconArrowRight)
        return iv
    }()
    
    private lazy var endTimeButton: TimeDisplayView = {
        let button = TimeDisplayView(timeCase: .end)
        button.addTarget(self, action: #selector(endTimeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var timeDisplayStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [startTimeButton, arrowImageView, endTimeButton])
        stack.axis         = .horizontal
        stack.alignment    = .center
        stack.distribution = .fill
        return stack
    }()
    
    private var wheelPicker: TimeWheelPickerView!
    
    private lazy var confirmButton: AppButton = {
        let button = AppButton()
        button.setTitle("확인", for: .normal)
        button.applyStyle(.primary())
        button.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        return button
    }()
    
    /// 옵션 버튼 (예: "오늘 휴가") — optionTitle이 nil이면 숨김
    private lazy var optionButton: AppButton = {
        let button = AppButton()
        button.applyStyle(.tertiary())
        button.addTarget(self, action: #selector(optionButtonTapped), for: .touchUpInside)
        return button
    }()
    
    /// confirmButton만 쓸 때: 단독 / optionButton도 있을 때: 가로 배치
    private lazy var buttonStack: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [optionButton, confirmButton])
        sv.axis         = .horizontal
        sv.spacing      = 12
        sv.distribution = .fillEqually
        return sv
    }()
    
    // MARK: - Initialization
    
    /// - Parameters:
    ///   - startTime: 초기 출근 시각
    ///   - endTime: 초기 퇴근 시각
    ///   - selectionMode: 초기 선택 모드
    ///   - isEndTimeOnly: true → 출근 버튼 탭 불가 (퇴근 시간만 수정 모드)
    ///   - optionTitle: 옵션 버튼 타이틀. nil이면 버튼 숨김, 확인 버튼 단독 표시
    init(
        startTime:    TimeIndicatorEntity,
        endTime:      TimeIndicatorEntity,
        selectionMode: TimeSelectionMode = .selectingStart,
        isEndTimeOnly: Bool = false,
        optionTitle:  String? = nil
    ) {
        self.selectedStartTime = startTime
        self.selectedEndTime   = endTime
        self.selectionMode     = isEndTimeOnly ? .selectingEnd : selectionMode
        self.isEndTimeOnly     = isEndTimeOnly
        
        super.init(frame: .zero)
        
        // 퇴근 시간만 수정 모드: 출근 버튼 탭 불가
        startTimeButton.isUserInteractionEnabled = !isEndTimeOnly
        startTimeButton.setActive(!isEndTimeOnly)
        
        // 옵션 버튼
        if let title = optionTitle {
            optionButton.setTitle(title, for: .normal)
            optionButton.isHidden = false
        } else {
            optionButton.isHidden = true
        }
        
        wheelPicker = TimeWheelPickerView(
            initialHour:   isEndTimeOnly ? endTime.hour   : startTime.hour,
            initialMinute: isEndTimeOnly ? endTime.minute : startTime.minute
        )
        wheelPicker.delegate = self
        
        setupViews(hasOption: optionTitle != nil)
        
        updateTimeDisplay()
        updateDurationView()
        updateSelectionState()
        updateConfirmButtonState()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Setup
    
    private func setupViews(hasOption: Bool) {
        backgroundColor = AppColor.Container.primary
        
        addSubview(durationView)
        addSubview(timeDisplayStackView)
        
        durationView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().inset(AppSpacing.screenHorizontal)
        }
        
        timeDisplayStackView.snp.makeConstraints {
            $0.top.equalTo(durationView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
            $0.height.equalTo(55)
        }
        
        arrowImageView.snp.makeConstraints { $0.width.height.equalTo(24) }
        startTimeButton.snp.makeConstraints { $0.width.equalTo(endTimeButton) }
        
        addSubview(wheelPicker)
        wheelPicker.snp.makeConstraints {
            $0.top.equalTo(timeDisplayStackView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
        }
        
        if hasOption {
            // 옵션 + 확인 가로 배치
            addSubview(buttonStack)
            buttonStack.snp.makeConstraints {
                $0.top.equalTo(wheelPicker.snp.bottom).offset(20)
                $0.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
                $0.height.equalTo(64)
                $0.bottom.lessThanOrEqualToSuperview().inset(24)
            }
        } else {
            // 확인 단독
            addSubview(confirmButton)
            confirmButton.snp.makeConstraints {
                $0.top.equalTo(wheelPicker.snp.bottom).offset(20)
                $0.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
                $0.height.equalTo(64)
                $0.bottom.lessThanOrEqualToSuperview().inset(24)
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func startTimeButtonTapped() {
        guard !isEndTimeOnly else { return }
        selectionMode = .selectingStart
        updateSelectionState()
        updateConfirmButtonState()
        wheelPicker.setTime(hour: selectedStartTime.hour, minute: selectedStartTime.minute, animated: true)
    }
    
    @objc private func endTimeButtonTapped() {
        selectionMode = .selectingEnd
        updateSelectionState()
        updateConfirmButtonState()
        wheelPicker.setTime(hour: selectedEndTime.hour, minute: selectedEndTime.minute, animated: true)
    }
    
    @objc private func confirmButtonTapped() {
        switch selectionMode {
        case .selectingStart:
            // 출근 선택 완료 → 퇴근 선택으로 넘어감
            selectionMode = .selectingEnd
            updateSelectionState()
            wheelPicker.setTime(hour: selectedEndTime.hour, minute: selectedEndTime.minute, animated: true)
            
        case .selectingEnd, .completed:
            selectionMode = .completed
            updateSelectionState()
            delegate?.timeSelectionView(self, didConfirmStartTime: selectedStartTime, endTime: selectedEndTime)
        }
    }
    
    @objc private func optionButtonTapped() {
        delegate?.timeSelectionViewDidTapOption(self)
    }
    
    // MARK: - Private Helpers
    
    private func updateTimeDisplay() {
        startTimeButton.setTime(selectedStartTime)
        endTimeButton.setTime(selectedEndTime)
    }
    
    private func updateSelectionState() {
        switch selectionMode {
        case .selectingStart:
            startTimeButton.setActive(true)
            endTimeButton.setActive(false)
        case .selectingEnd, .completed:
            startTimeButton.setActive(isEndTimeOnly ? false : false)
            endTimeButton.setActive(true)
        }
    }
    
    private func updateDurationView() {
        durationView.configure(
            start: selectedStartTime.displayString,
            end: selectedEndTime.displayString
        )
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
        
        updateDurationView()
        updateConfirmButtonState()
    }
    
    private func updateConfirmButtonState() {
        
        let isSameTime =
        selectedStartTime.hour == selectedEndTime.hour &&
        selectedStartTime.minute == selectedEndTime.minute
        
        confirmButton.isEnabled = !isSameTime
    }
}
