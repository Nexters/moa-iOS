//
//  TimeRangeRowView.swift
//  Moa
//
//  Created by mirim on 2/6/26.
//

import UIKit
import SnapKit

final class TimeRangeRowView: UIControl {
    
    // MARK: - UI
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.layer.cornerRadius = 12
        stack.layer.masksToBounds = true
        stack.backgroundColor = AppColor.Container.primary
        return stack
    }()
    
    private let startTimeLabel: UILabel = {
        let label = StyledLabel()
        label.textStyle = .init(
            typography: AppTypography.t2_700,
            color: AppColor.IconAndText.highEmphasis
        )
        label.textAlignment = .center
        label.text = "09:00"
        return label
    }()
    
    private let endTimeLabel: UILabel = {
        let label = StyledLabel()
        label.textStyle = .init(
            typography: AppTypography.t2_700,
            color: AppColor.IconAndText.highEmphasis
        )
        label.textAlignment = .center
        label.text = "18:00"
        return label
    }()
    
    private let arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(resource: .Icon.iconArrowRight)
        return imageView
    }()
    
    private let leftArea = UILayoutGuide()
    private let rightArea = UILayoutGuide()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupInteraction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    
    func configure(start: String, end: String) {
        startTimeLabel.text = start
        endTimeLabel.text = end
    }
    
    // MARK: - Private
    
    private func setupUI() {
        addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.greaterThanOrEqualTo(60)
        }
        
        stackView.addLayoutGuide(leftArea)
        stackView.addLayoutGuide(rightArea)
        
        stackView.addSubViews([startTimeLabel, arrowImageView, endTimeLabel])
        
        arrowImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        leftArea.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.trailing.equalTo(arrowImageView.snp.leading)
        }
        
        rightArea.snp.makeConstraints { make in
            make.leading.equalTo(arrowImageView.snp.trailing)
            make.top.bottom.trailing.equalToSuperview()
        }
        
        leftArea.widthAnchor.constraint(equalTo: rightArea.widthAnchor).isActive = true
        
        startTimeLabel.snp.makeConstraints { make in
            make.centerX.equalTo(leftArea.snp.centerX)
            make.leading.equalToSuperview().inset(20)
            make.trailing.lessThanOrEqualTo(leftArea.snp.trailing).inset(10)
            make.centerY.equalToSuperview()
        }
        
        endTimeLabel.snp.makeConstraints { make in
            make.centerX.equalTo(rightArea.snp.centerX)
            make.trailing.equalToSuperview().inset(20)
            make.leading.greaterThanOrEqualTo(rightArea.snp.leading).inset(10)
            make.centerY.equalToSuperview()
        }
    }
    
    private func setupInteraction() {
        addTarget(self, action: #selector(rowTapped), for: .touchUpInside)
    }
    
    @objc private func rowTapped() {
        sendActions(for: .primaryActionTriggered)
    }
}
