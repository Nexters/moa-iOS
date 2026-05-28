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
    
    private lazy var rootStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [stackView, durationView])
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.layer.cornerRadius = 12
        stack.layer.masksToBounds = true
        stack.backgroundColor = AppColor.Container.primary
        return stack
    }()
    
    private let durationView = WorkDurationView()
    
    private lazy var startTimeLabel: StyledLabel = {
        let label = StyledLabel()
        label.setStyle(
            .init(
                typography: AppTypography.t2_700,
                color: AppColor.IconAndText.highEmphasis
            )
        )
        label.textAlignment = .center
        return label
    }()
    
    private lazy var endTimeLabel: StyledLabel = {
        let label = StyledLabel()
        label.setStyle(
            .init(
                typography: AppTypography.t2_700,
                color: AppColor.IconAndText.highEmphasis
            )
        )
        label.textAlignment = .center
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
        startTimeLabel.setText(start)
        endTimeLabel.setText(end)

        durationView.configure(start: start, end: end)
    }
    
    // MARK: - Private
    
    private func setupUI() {
        addSubview(rootStackView)

        rootStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        stackView.snp.makeConstraints {
            $0.height.greaterThanOrEqualTo(60)
        }

        setupTimeRowLayout()
    }
    
    private func setupTimeRowLayout() {
        stackView.addLayoutGuide(leftArea)
        stackView.addLayoutGuide(rightArea)
        
        stackView.addSubViews([startTimeLabel, arrowImageView, endTimeLabel])
        
        arrowImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(24)
        }
        
        leftArea.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.trailing.equalTo(arrowImageView.snp.leading)
        }
        
        rightArea.snp.makeConstraints {
            $0.leading.equalTo(arrowImageView.snp.trailing)
            $0.top.bottom.trailing.equalToSuperview()
        }
        
        leftArea.widthAnchor.constraint(equalTo: rightArea.widthAnchor).isActive = true
        
        startTimeLabel.snp.makeConstraints {
            $0.centerX.equalTo(leftArea.snp.centerX)
            $0.leading.equalToSuperview().inset(20)
            $0.trailing.lessThanOrEqualTo(leftArea.snp.trailing).inset(10)
            $0.centerY.equalToSuperview()
        }
        
        endTimeLabel.snp.makeConstraints {
            $0.centerX.equalTo(rightArea.snp.centerX)
            $0.trailing.equalToSuperview().inset(20)
            $0.leading.greaterThanOrEqualTo(rightArea.snp.leading).inset(10)
            $0.centerY.equalToSuperview()
        }
    }
    
    private func setupInteraction() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(rowTapped))
        addGestureRecognizer(tap)
        isUserInteractionEnabled = true
    }
    
    @objc private func rowTapped() {
        sendActions(for: .touchUpInside)
    }
}
