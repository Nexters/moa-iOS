//
//  ScheduleDateRangeCardView.swift
//  Moa
//
//  날짜 구간 선택 카드
//  - 미선택: 아이콘 + placeholder 텍스트 (disabled 색상)
//  - 선택됨: "2026.02.21" 또는 "2026.02.21 ~ 2026.02.25" (highEmphasis 색상)
//  - 탭 → onTap 클로저 호출 (FixScheduleVC가 캘린더 바텀시트 오픈)
//

import UIKit
import SnapKit

final class ScheduleDateRangeCardView: UIView {
    
    // MARK: - Callback
    
    var onTap: (() -> Void)?
    
    // MARK: - UI
    
    private let dateLabel: StyledLabel = {
        let label = StyledLabel()
        label.setStyle(
            .init(
                typography: AppTypography.b1_400,
                color: AppColor.IconAndText.lowEmphasis
            )
        )
        label.numberOfLines = 1
        return label
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        setupGesture()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor    = AppColor.Container.primary
        layer.cornerRadius = 12
        clipsToBounds      = true
        
        addSubview(dateLabel)
       
        dateLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
        }
    }
    
    private func setupGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTap))
        
        addGestureRecognizer(tap)
        isUserInteractionEnabled = true
    }
    
    // MARK: - Configure
    
    func configure(dateRange: ScheduleDateRange?) {
        let isSelected = dateRange != nil
        let font  = isSelected ? AppTypography.t2_700 : AppTypography.t2_400
        let textColor  = isSelected ? AppColor.IconAndText.highEmphasis : AppColor.IconAndText.lowEmphasis
        
        dateLabel.setText(
            dateRange?.displayString ?? "날짜를 선택해주세요",
            style: .init(
                typography: font,
                color: textColor
            )
        )
    }
    
    // MARK: - Action
    
    @objc private func didTap() {
        onTap?()
    }
}
