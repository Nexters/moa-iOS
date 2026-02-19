//
//  EarningsStackView.swift
//  Moa
//
//  Created by 정도현 on 2/18/26.
//

import UIKit
import SnapKit

// MARK: - EarningsStackView

final class EarningsStackView: UIView {

    // MARK: - Constants

    private enum Constants {
        static let minHeightRatio: CGFloat = 0.30  // 화면의 30%
        static let maxHeightRatio: CGFloat = 0.70  // 화면의 70%
 
        static let growthDuration: TimeInterval = 30 * 60    // 30분
        static let tooltipInterval: TimeInterval = 5.0     // 5초

        static let tooltipMessages = [
            "커피와 조각 케이크를 살 수 있어요",
            "치킨 한 마리 살 수 있어요",
            "오늘 쌓은 월급 150,000원"
        ]
        
        static let solidMaskHeight: CGFloat = 90
        static let gradientMaskHeight: CGFloat = 60
    }

    // MARK: - UI
    private let workingType: WorkingType

    // 기둥 위에서 움직이는 정보 세트 컨테이너
    private let floatingInfoContainer = UIView()

    // 툴팁 말풍선
    private let tooltipView = SpeechBubble()

    // title
    private let titleLabel: StyledLabel = {
        let label = StyledLabel()
        label.setText(
            "오늘 쌓은 월급",
            style: .init(
                typography: AppTypography.b1_400,
                color: AppColor.IconAndText.mediumEmphasis
            )
        )
        label.textAlignment = .center
        return label
    }()

    // 금액 라벨
    private let amountLabel: StyledLabel = {
        let label = StyledLabel()
        label.setStyle(
            .init(
                typography: AppTypography.h1_700,
                color: AppColor.IconAndText.highEmphasis
            )
        )
        label.textAlignment = .center
        return label
    }()

    // 기둥 컨테이너 (클리핑용)
    private let stackContainer: UIView = {
        let view = UIView()
        return view
    }()

    // 기둥 이미지
    private lazy var stackImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = workingType.stackImage
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        return imageView
    }()

    private let maskGradientLayer = CAGradientLayer()

    // MARK: - Properties

    private var stackBottomConstraint: Constraint?
    private var floatingContainerBottomConstraint: Constraint?
    
    private var tooltipTimer: Timer?
    private var currentTooltipIndex = 0

    private var growthStartTime: Date?
    private var growthDisplayLink: CADisplayLink?
    
    private var hasAppliedInitialPosition = false

    // MARK: - Init

    init(workingType: WorkingType) {
        self.workingType = workingType
        super.init(frame: .zero)
        setupUI()
        setupMask()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        stopAnimations()
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()

        // 초기 위치 설정
        if !hasAppliedInitialPosition, stackContainer.bounds.height > 0 {
            hasAppliedInitialPosition = true
            applyInitialPosition()
        }
        
        updateMaskLayout()
    }
    
    private func applyInitialPosition() {
        let containerHeight = stackContainer.bounds.height
        let initialOffset = containerHeight * (1 - Constants.minHeightRatio)
        stackBottomConstraint?.update(offset: initialOffset)
        
        updateFloatingContainerPosition(ratio: Constants.minHeightRatio)
        
        layoutIfNeeded()
    }

    // MARK: - Setup

    private func setupUI() {
        floatingInfoContainer.addSubViews([
            tooltipView,
            titleLabel,
            amountLabel
        ])

        addSubViews([
            stackContainer
        ])

        stackContainer.addSubViews([
            floatingInfoContainer,
            stackImageView
        ])

        // floating 컨테이너 내부 레이아웃
        tooltipView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(tooltipView.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
        }

        amountLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview()
        }

        // 스택 컨테이너
        stackContainer.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalToSuperview().offset(88)
        }

        // 기둥 이미지
        stackImageView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(stackContainer.snp.height)
            stackBottomConstraint = $0.bottom.equalToSuperview().constraint
        }

        // floating 컨테이너
        floatingInfoContainer.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.centerX.equalToSuperview()
            floatingContainerBottomConstraint = $0.bottom.equalToSuperview().constraint
        }
    }
    
    // 마스킹 설정
    private func setupMask() {
        layer.mask = maskGradientLayer
        
        maskGradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        maskGradientLayer.endPoint   = CGPoint(x: 0.5, y: 1)
    }
    
    private func updateMaskLayout() {
        let height = bounds.height
        guard height > 0 else { return }
        
        maskGradientLayer.frame = bounds
        
        let solid = Constants.solidMaskHeight
        let gradient = Constants.gradientMaskHeight
        
        let solidStart = 1 - (solid / height)
        let gradientStart = 1 - ((solid + gradient) / height)
        
        maskGradientLayer.colors = [
            UIColor.white.cgColor,
            UIColor.white.cgColor,
            UIColor.white.withAlphaComponent(0.7).cgColor,
            UIColor.white.withAlphaComponent(0.3).cgColor,
            UIColor.white.withAlphaComponent(0.0).cgColor
        ]
        
        maskGradientLayer.locations = [
            0.0,
            NSNumber(value: Float(gradientStart * 0.9)),
            NSNumber(value: Float(gradientStart)),
            NSNumber(value: Float(solidStart)),
            1.0
        ]
    }

    // MARK: - Configure

    /// 초기 데이터 설정 및 애니메이션 시작
    func configure(amount: Int) {
        updateAmount(amount)
        
        // 레이아웃 강제 업데이트 후 애니메이션 시작
        layoutIfNeeded()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.startAnimations()
        }
    }

    /// 금액만 업데이트 (애니메이션 재시작 없음)
    func updateAmount(_ amount: Int) {
        let formatted = AppNumberFormatter.decimalString(from: amount)
        amountLabel.setText("\(formatted)원")
    }

    // MARK: - Animations

    /// 모든 애니메이션 시작
    func startAnimations() {
        startTooltipRotation()
        startStackGrowth()
    }

    /// 모든 애니메이션 정지
    func stopAnimations() {
        stopTooltipRotation()
        stopStackGrowth()
    }

    // MARK: - Tooltip Animation

    private func startTooltipRotation() {
        // 5초 후 첫 툴팁 표시
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.tooltipInterval) { [weak self] in
            self?.showNextTooltip()
        }
    }

    private func stopTooltipRotation() {
        tooltipTimer?.invalidate()
        tooltipTimer = nil
    }

    private func showNextTooltip() {
        let message = Constants.tooltipMessages[currentTooltipIndex]
        tooltipView.configure(text: message)

        // 페이드 인
        UIView.animate(withDuration: 0.3) {
            self.tooltipView.alpha = 1
        } completion: { _ in
            // 3초 후 페이드 아웃
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                self?.hideTooltip()
            }
        }

        // 다음 인덱스
        currentTooltipIndex = (currentTooltipIndex + 1) % Constants.tooltipMessages.count
    }

    private func hideTooltip() {
        UIView.animate(withDuration: 0.3) {
            self.tooltipView.alpha = 0
        } completion: { [weak self] _ in
            // 다음 툴팁 예약
            self?.tooltipTimer = Timer.scheduledTimer(
                withTimeInterval: Constants.tooltipInterval,
                repeats: false
            ) { [weak self] _ in
                self?.showNextTooltip()
            }
        }
    }

    // MARK: - Stack Growth Animation

    private func startStackGrowth() {
        growthStartTime = Date()
        growthDisplayLink = CADisplayLink(
            target: self,
            selector: #selector(updateStackPosition)
        )
        growthDisplayLink?.add(to: .main, forMode: .common)
    }

    private func stopStackGrowth() {
        growthDisplayLink?.invalidate()
        growthDisplayLink = nil
    }

    @objc
    private func updateStackPosition() {
        guard let startTime = growthStartTime else { return }

        let elapsed = Date().timeIntervalSince(startTime)
        let cycleElapsed = elapsed.truncatingRemainder(dividingBy: Constants.growthDuration)
        let progress = cycleElapsed / Constants.growthDuration  // 0.0 ~ 1.0

        // ease-out
        let easedProgress = easeOutQuad(CGFloat(progress))

        // 30% → 70%
        let currentRatio = Constants.minHeightRatio +
            (Constants.maxHeightRatio - Constants.minHeightRatio) * easedProgress

        let containerHeight = stackContainer.bounds.height
        guard containerHeight > 0 else { return }

        // offset: 보이지 않는 부분 = (1 - 현재비율) * 전체높이
        let offset = containerHeight * (1 - currentRatio)
        stackBottomConstraint?.update(offset: offset)
        
        // floating 컨테이너 위치도 업데이트
        updateFloatingContainerPosition(ratio: currentRatio)
    }
    
    /// floating 컨테이너를 기둥 상단에 위치시킴
    private func updateFloatingContainerPosition(ratio: CGFloat) {
        let containerHeight = stackContainer.bounds.height
        guard containerHeight > 0 else { return }
        
        let visibleHeight = containerHeight * ratio
        
        let offset = -visibleHeight - 20
        floatingContainerBottomConstraint?.update(offset: offset)
    }

    /// Ease-out quad: 빠르게 시작 → 천천히 끝
    private func easeOutQuad(_ t: CGFloat) -> CGFloat {
        return t * (2 - t)
    }
}
