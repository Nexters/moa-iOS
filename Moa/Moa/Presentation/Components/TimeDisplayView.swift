//
//  TimeDisplayView.swift
//  Moa
//
//  Created by 정도현 on 2/15/26.
//

import UIKit
import SnapKit

enum TimeDisplayCase: String {
    case start
    case end
    
    var description: String {
        switch self {
        case .start:
            return "출근"
        case .end:
            return "퇴근"
        }
    }
}

final class TimeDisplayView: UIButton {
    
    // MARK: - Properties
    private var isActive: Bool = false
    
    // MARK: - UI Components
    lazy var headerLabel: StyledLabel = {
        let label = StyledLabel()
        label.setStyle(
            .init(
                typography: AppTypography.b2_500,
                color: AppColor.IconAndText.lowEmphasis
            )
        )
        label.textAlignment = .center
        label.isUserInteractionEnabled = false
        return label
    }()
    
    private lazy var timeValueLabel: StyledLabel = {
        let label = StyledLabel()
        label.setStyle(
            .init(
                typography: AppTypography.t1_700,
                color: AppColor.IconAndText.lowEmphasis
            )
        )
        label.textAlignment = .center
        label.isUserInteractionEnabled = false
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [headerLabel, timeValueLabel])
        stack.axis = .vertical
        stack.spacing = 0
        stack.alignment = .center
        stack.isUserInteractionEnabled = false
        return stack
    }()
    
    // MARK: - Initialization
    init(timeCase: TimeDisplayCase) {
        super.init(frame: .zero)
        
        setupViews()
        headerLabel.setText(timeCase.description)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupViews() {
        addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(0)
        }
    }
    
    // MARK: - Public Methods
    func setTime(_ time: TimeIndicatorEntity) {
        timeValueLabel.setText(time.displayString)
    }
    
    func setActive(_ active: Bool) {
        isActive = active
        
        timeValueLabel.setStyle(
            .init(
                typography: AppTypography.t1_700,
                color: active
                ? AppColor.IconAndText.green
                : AppColor.IconAndText.lowEmphasis
            )
        )
    }
}
