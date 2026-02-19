//
//  WorkStatusBadge.swift
//  Moa
//
//  Created by 정도현 on 2/18/26.
//


import UIKit
import SnapKit

// MARK: - BadgeType

enum BadgeType {
    case working      // 근무 중
    case lunch        // 점심시간
    case vacation     // 휴가
    case overtime     // 추가 근무
    
    var text: String {
        switch self {
        case .working:  return "근무 중"
        case .lunch:    return "점심시간"
        case .vacation: return "휴가"
        case .overtime: return "추가 근무"
        }
    }
    
    var indicateColor: UIColor {
        switch self {
        case .working:  return AppColor.IconAndText.green
        case .lunch:    return AppColor.IconAndText.blue
        case .vacation: return AppColor.IconAndText.blue
        case .overtime: return AppColor.IconAndText.error
        }
    }
}

// MARK: - StatusBadgeView

final class StatusBadgeView: UIView {
    
    // MARK: - UI
    
    private let label: StyledLabel = {
        let label = StyledLabel()
        label.setStyle(
            .init(
                typography: AppTypography.b2_500,
                color: AppColor.IconAndText.green
            )
        )
        return label
    }()
    
    // MARK: - Properties
    
    private var badgeType: BadgeType
    
    // MARK: - Init
    
    init(type: BadgeType) {
        self.badgeType = type
        super.init(frame: .zero)
        
        setupUI()
        configure(type: type)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        layer.cornerRadius = 8
        layer.borderWidth = 1
        clipsToBounds = true
        
        addSubview(label)
        label.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(4)
            $0.leading.trailing.equalToSuperview().inset(10)
        }
    }
    
    // MARK: - Configure
    
    func configure(type: BadgeType) {
        self.badgeType = type
        
        label.setText(
            type.text,
            style: .init(
                typography: AppTypography.b2_500,
                color: type.indicateColor
            )
        )
        
        layer.borderColor = type.indicateColor.cgColor
    }
    
    /// 뱃지 타입만 변경
    func updateType(_ type: BadgeType) {
        configure(type: type)
    }
}
