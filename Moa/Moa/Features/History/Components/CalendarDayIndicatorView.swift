//
//  CalendarDayIndicatorView.swift
//  Moa
//
//  Created by 정도현 on 2/19/26.
//

import UIKit
import SnapKit

final class CalendarDayIndicatorView: UIView {
    
    private let dotView: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 3
        v.isHidden = true
        return v
    }()
    
    private let labelStack: UIStackView = {
        let sv = UIStackView()
        sv.axis      = .horizontal
        sv.spacing   = 2
        sv.alignment = .center
        sv.isHidden  = true
        return sv
    }()
    
    private let primaryLabel   = CalendarDayIndicatorView.makeLabel()
    private let separatorLabel = CalendarDayIndicatorView.makeLabel()
    private let secondaryLabel = CalendarDayIndicatorView.makeLabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        labelStack.addArrangedSubview(primaryLabel)
        labelStack.addArrangedSubview(separatorLabel)
        labelStack.addArrangedSubview(secondaryLabel)
        
        addSubViews([dotView, labelStack])
        
        dotView.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 6, height: 6))
            $0.center.equalToSuperview()
        }
        labelStack.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.lessThanOrEqualToSuperview()
        }
    }
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Configure
    
    func configure(type: CalendarDayType) {
        dotView.isHidden        = true
        dotView.backgroundColor = .clear
        
        // labelStack + 하위 레이블 전체
        labelStack.isHidden     = true
        primaryLabel.isHidden   = false
        separatorLabel.isHidden = true
        secondaryLabel.isHidden = true
        
        primaryLabel.text   = nil
        separatorLabel.text = nil
        secondaryLabel.text = nil
        
        switch type {
            
        case .scheduled:
            dotView.isHidden        = false
            dotView.backgroundColor = AppColor.Container.secondary
            
        case .worked:
            dotView.isHidden        = false
            dotView.backgroundColor = AppColor.IconAndText.green
            
        case .dualLabel:
            labelStack.isHidden     = false
            separatorLabel.isHidden = false
            secondaryLabel.isHidden = false
            primaryLabel.setText(
                "월급",
                style: .init(typography: AppTypography.c1_400, color: AppColor.IconAndText.green)
            )
            separatorLabel.setText(
                "·",
                style: .init(typography: AppTypography.c1_400, color: AppColor.IconAndText.mediumEmphasis)
            )
            secondaryLabel.setText(
                "휴가",
                style: .init(typography: AppTypography.c1_400, color: AppColor.IconAndText.mediumEmphasis)
            )
            
        case .singleLabel(let style):
            labelStack.isHidden = false
            switch style {
            case .payday:
                primaryLabel.setText(
                    "월급",
                    style: .init(typography: AppTypography.c1_400, color: AppColor.IconAndText.green)
                )
            case .vacation:
                primaryLabel.setText(
                    "휴가",
                    style: .init(typography: AppTypography.c1_400, color: AppColor.IconAndText.mediumEmphasis)
                )
            }
            
        default:
            break
        }
    }
    
    private static func makeLabel() -> StyledLabel {
        let l = StyledLabel()
        l.setStyle(.init(typography: AppTypography.c1_400, color: AppColor.IconAndText.mediumEmphasis))
        l.textAlignment = .center
        return l
    }
}
