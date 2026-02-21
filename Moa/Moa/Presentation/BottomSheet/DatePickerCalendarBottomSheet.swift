//
//  DatePickerCalendarBottomSheet.swift
//  Moa
//
//  Created by 정도현 on 2/20/26.
//

import UIKit
import SnapKit

// MARK: - Simple Test Bottom Sheet Delegate
protocol DatePickerCalendarBottomSheetDelegate: AnyObject {
    func calendarBottomSheet(_ sheet: DatePickerCalendarBottomSheet, didSelect date: Date)
}

final class DatePickerCalendarBottomSheet: UIViewController, BottomSheetPresentable {
    
    // MARK: - Properties
    weak var delegate: DatePickerCalendarBottomSheetDelegate?
    
    // MARK: - UI

    private let titleLabel: StyledLabel = {
        let label = StyledLabel()
        label.setText(
            "날짜를 선택해주세요!",
            style: .init(
                typography: AppTypography.t1_700,
                color: AppColor.IconAndText.highEmphasis
            ))
        label.numberOfLines = 1
        return label
    }()

    private let calendarView = DatePickerCalendarView()
    
    private lazy var confirmButton: AppButton = {
        let button = AppButton()
        button.setTitle("확인", for: .normal)
        button.applyStyle(.primary())
        return button
    }()
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        calendarView.delegate = self
        confirmButton.isEnabled = false
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        view.backgroundColor = AppColor.Container.primary
        
        view.addSubViews([titleLabel, calendarView, confirmButton])
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
        }
        
        calendarView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.height.equalTo(386)
            make.leading.trailing.equalToSuperview().inset(8)
        }
        
        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(calendarView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
            make.height.equalTo(64)
            make.bottom.equalToSuperview().inset(24)
        }

        confirmButton.addTarget(self, action: #selector(didTapConfirmButton), for: .touchUpInside)
    }
    
    
    @objc private func didTapConfirmButton() {
        
        guard let selectedDate = calendarView.selectedDate else { return }
        
        delegate?.calendarBottomSheet(self, didSelect: selectedDate)
        dismissBottomSheet()
    }
    
    private func dismissBottomSheet() {
        (parent as? BottomSheetViewController)?.animateDismiss()
    }
}

extension DatePickerCalendarBottomSheet: DatePickerCalendarViewDelegate {
    
    func datePickerCalendarView(_ view: DatePickerCalendarView, didSelectDate date: Date) {
        confirmButton.isEnabled = true
    }
}


@available(iOS 17.0)
#Preview {
    DatePickerCalendarBottomSheet()
}
