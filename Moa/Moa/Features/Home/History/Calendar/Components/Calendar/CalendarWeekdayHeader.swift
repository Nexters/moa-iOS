//
//  CalendarWeekdayHeader.swift
//  Moa
//
//  Created by 정도현 on 2/19/26.
//

import UIKit
import SnapKit

final class CalendarWeekdayHeader: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        addSubview(stack)
        stack.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        ["일", "월", "화", "수", "목", "금", "토"].forEach {
            let label = StyledLabel()
            label.setText($0, style: .init(typography: AppTypography.b2_400, color: AppColor.IconAndText.mediumEmphasis))
            label.textAlignment = .center
            stack.addArrangedSubview(label)
        }
    }
    required init?(coder: NSCoder) { fatalError() }
}
