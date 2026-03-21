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
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = AppTypography.b1_400.font()
        label.textColor = AppColor.IconAndText.lowEmphasis
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
            $0.height.equalTo(60)
            $0.centerY.equalToSuperview()
        }
    }
    
    private func setupGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTap))
        
        addGestureRecognizer(tap)
        isUserInteractionEnabled = true
    }
    
    // MARK: - Configure
    
    func configure(dateRange: ScheduleDateRangeEntity?) {
        let isSelected = dateRange != nil
        let font  = isSelected ? AppTypography.t2_700 : AppTypography.t2_400
        let textColor  = isSelected ? AppColor.IconAndText.highEmphasis : AppColor.IconAndText.lowEmphasis

        dateLabel.text = dateRange?.displayString ?? Date().koreanDateString
        dateLabel.font = font.font()
        dateLabel.textColor = textColor
    }
    
    // MARK: - Action
    
    @objc private func didTap() {
        onTap?()
    }
}
