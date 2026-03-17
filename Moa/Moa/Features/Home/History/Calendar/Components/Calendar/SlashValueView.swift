//
//  SlashValueView.swift
//  Moa
//
//  Created by 정도현 on 3/17/26.
//

import UIKit
import SnapKit

final class SlashValueView: UIView {

    // MARK: - Subviews

    private let currentLabel  = SlashValueView.makeLabel()
    private let totalLabel    = SlashValueView.makeLabel()

    private let stack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis      = .horizontal
        stackView.spacing   = 6
        return stackView
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        stack.addArrangedSubview(currentLabel)
        stack.addArrangedSubview(totalLabel)
        
        addSubview(stack)
        
        stack.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
    
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Configure
    
    func configure(current: Int, total: Int, unit: String) {
        currentLabel.setText(AppNumberFormatter.decimalString(from: current), style: .init(
            typography: AppTypography.b1_600,
            color: AppColor.IconAndText.green
        ))
        totalLabel.setText("/ \(AppNumberFormatter.decimalString(from: total))\(unit)", style: .init(
            typography: AppTypography.b1_400,
            color: AppColor.IconAndText.mediumEmphasis
        ))
    }

    // MARK: - Factory

    private static func makeLabel() -> StyledLabel {
        let label = StyledLabel()
        label.textAlignment = .right
        return label
    }
}
