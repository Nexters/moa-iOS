//
//  SpeechBubble.swift
//  Moa
//
//  Created by 정도현 on 2/4/26.
//

import UIKit
import SnapKit

/// 중앙 하단 삼각형 꼬리를 가진 말풍선 입니다.
final class SpeechBubble: UIView {
    
    // MARK: - Properties
    private let tailHeight: CGFloat = 9.34
    private let cornerRadius: CGFloat = 16
    
    private lazy var contentLabel: StyledLabel = {
        let label = StyledLabel()
        label.setStyle(
            .init(
                typography: AppTypography.b2_400,
                color: AppColor.IconAndText.highEmphasis
            )
        )
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var backgroundShapeLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = AppColor.Background.secondary.cgColor
        return layer
    }()
    
    // MARK: - Init
    init(text: String) {
        super.init(frame: .zero)
        
        setupUI()
        configure(text: text)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        layer.insertSublayer(backgroundShapeLayer, at: 0)
        addSubview(contentLabel)
        
        contentLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.leading.trailing.equalToSuperview().inset(14)
            $0.bottom.equalToSuperview().offset(-8 - tailHeight)
        }
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        updateBubblePath()
    }
    
    private func updateBubblePath() {
        let bubblePath = UIBezierPath()
        let width = bounds.width
        let height = bounds.height - tailHeight
        
        // 말풍선 본체
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        let roundedRect = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
        bubblePath.append(roundedRect)
        
        // 하단 중앙 삼각형 꼬리
        let tailWidth: CGFloat = 17.32
        let centerX = width / 2
        let tailTop = height
        
        bubblePath.move(to: CGPoint(x: centerX - tailWidth / 2, y: tailTop))
        bubblePath.addLine(to: CGPoint(x: centerX, y: tailTop + tailHeight))
        bubblePath.addLine(to: CGPoint(x: centerX + tailWidth / 2, y: tailTop))
        bubblePath.close()
        
        backgroundShapeLayer.path = bubblePath.cgPath
    }
    
    // MARK: - Configuration
    func configure(text: String) {
        contentLabel.setText(text)
    }
}
