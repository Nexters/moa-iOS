//
//  DividerView.swift
//  Moa
//
//  Created by mirim on 2/14/26.
//

import SwiftUI
import SnapKit

final class DividerView: UIView {
    init(
        color: UIColor = AppColor.Divider.secondary,
        inset: CGFloat = 0
    ) {
        super.init(frame: .zero)
        backgroundColor = color
        
        snp.makeConstraints { $0.height.equalTo(1.0 / UIScreen.main.scale) }
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
