//
//  MoneyStackView.swift
//  Moa
//

import UIKit
import SnapKit

// MARK: - EarningsStackView

final class EarningsStackView: UIView {
    
    // MARK: - Constants
    
    private enum Constants {
        static let minHeightRatio: CGFloat      = 0.30
        static let maxHeightRatio: CGFloat      = 0.70
        static let endHeightRatio: CGFloat      = 0.84
        static let growthDuration: TimeInterval = 30 * 60
        static let tooltipInterval: TimeInterval = 5.0
        static let tooltipDisplay:  TimeInterval = 3.0
        static let solidMaskHeight: CGFloat     = 90
        static let gradientMaskHeight: CGFloat  = 60
    }
    
    // MARK: - Tooltip Thresholds
    
    private static let thresholds: [(minAmount: Int, message: String)] = [
        (10_000,  "커피와 조각 케이크를 살 수 있어요"),
        (20_000,  "치킨 한 마리 살 수 있어요"),
        (30_000,  "영화 2인 예매를 할 수 있어요"),
        (50_000,  "로지텍 무선 마우스를 살 수 있어요"),
        (100_000, "나이키 운동화 한 켤레를 살 수 있어요"),
        (200_000, "노스페이스 백팩을 살 수 있어요"),
        (250_000, "갤럭시 워치 FE를 살 수 있어요"),
        (300_000, "에어팟 3세대를 살 수 있어요"),
        (350_000, "아이패드 9세대를 살 수 있어요"),
        (400_000, "다이슨 무선 청소기를 살 수 있어요"),
        (450_000, "닌텐도 스위치를 살 수 있어요"),
        (500_000, "플레이스테이션 5를 살 수 있어요"),
    ]
    
    private static func tooltipMessage(for amount: Int) -> String? {
        thresholds.last(where: { amount >= $0.minAmount })?.message
    }
    
    // MARK: - UI
    
    private let floatingInfoContainer = UIView()
    private let tooltipView           = SpeechBubble()
    
    private let titleLabel: StyledLabel = {
        let label = StyledLabel()
        label.setText("오늘 쌓은 월급", style: .init(
            typography: AppTypography.b1_400,
            color: AppColor.IconAndText.mediumEmphasis
        ))
        label.textAlignment = .center
        return label
    }()
    
    private let rollingLabel = RollingAmountLabel()
    
    private let unitLabel: StyledLabel = {
        let label = StyledLabel()
        label.setText("원", style: .init(
            typography: AppTypography.h2_500,
            color: AppColor.IconAndText.mediumEmphasis
        ))
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()
    
    private lazy var amountRow: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [rollingLabel, unitLabel])
        sv.axis = .horizontal; sv.alignment = .center; sv.spacing = 2
        return sv
    }()
    
    private let stackContainer = UIView()
    
    private let stackImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode     = .scaleAspectFit
        iv.backgroundColor = .clear
        return iv
    }()
    
    private let maskGradientLayer = CAGradientLayer()
    
    // MARK: - State

    /// true이면 말풍선·성장 애니메이션 완전 차단
    private var isStopped = false
    
    private var stackBottomConstraint: Constraint?
    private var floatingContainerBottomConstraint: Constraint?
    
    private var growthCycleStart: Date?
    private var growthDisplayLink: CADisplayLink?
    private var hasAppliedInitialPosition = false
    
    private var tooltipTimer: Timer?
    private var lastTooltipMessage: String?
    private var currentAmount: Int = 0
    
    // MARK: - Init
    
    init(workingType: WorkingType) {
        super.init(frame: .zero)
        stackImageView.image = workingType.stackImage
        setupUI()
        setupMask()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    deinit { stopAnimations() }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !hasAppliedInitialPosition, stackContainer.bounds.height > 0 {
            hasAppliedInitialPosition = true
            applyInitialPosition()
        }
        updateMaskLayout()
    }
    
    private func applyInitialPosition() {
        let ratio = currentCycleRatio()
        let h     = stackContainer.bounds.height
        stackBottomConstraint?.update(offset: h * (1 - ratio))
        updateFloatingContainerPosition(ratio: ratio)
        layoutIfNeeded()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        floatingInfoContainer.addSubViews([tooltipView, titleLabel, amountRow])
        addSubViews([stackContainer])
        stackContainer.addSubViews([floatingInfoContainer, stackImageView])
        
        tooltipView.snp.makeConstraints {
            $0.top.centerX.equalToSuperview()
        }
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(tooltipView.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
        }
        amountRow.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.centerX.bottom.equalToSuperview()
        }
        stackContainer.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalToSuperview().offset(88)
        }
        stackImageView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(stackContainer.snp.height)
            stackBottomConstraint = $0.bottom.equalToSuperview().constraint
        }
        floatingInfoContainer.snp.makeConstraints {
            $0.leading.trailing.centerX.equalToSuperview()
            floatingContainerBottomConstraint = $0.bottom.equalToSuperview().constraint
        }
    }
    
    private func setupMask() {
        layer.mask = maskGradientLayer
        maskGradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        maskGradientLayer.endPoint   = CGPoint(x: 0.5, y: 1)
    }
    
    private func updateMaskLayout() {
        let h = bounds.height
        guard h > 0 else { return }
        maskGradientLayer.frame = bounds
        
        let solid         = Constants.solidMaskHeight
        let gradient      = Constants.gradientMaskHeight
        let solidStart    = 1 - (solid / h)
        let gradientStart = 1 - ((solid + gradient) / h)
        
        maskGradientLayer.colors = [
            UIColor.white.cgColor,
            UIColor.white.cgColor,
            UIColor.white.withAlphaComponent(0.7).cgColor,
            UIColor.white.withAlphaComponent(0.3).cgColor,
            UIColor.white.withAlphaComponent(0.0).cgColor,
        ]
        maskGradientLayer.locations = [
            0.0,
            NSNumber(value: Float(gradientStart * 0.9)),
            NSNumber(value: Float(gradientStart)),
            NSNumber(value: Float(solidStart)),
            1.0,
        ]
    }
    
    // MARK: - Configure
    
    /// - Parameter isFinished: true이면 성장 애니메이션 예약 자체를 차단 (근무완료1)
    func configure(amount: Int, startedAt: Date, isFinished: Bool = false) {
        currentAmount    = amount
        growthCycleStart = resolveCycleStart(from: startedAt)

        rollingLabel.setText(formatted(amount))
        layoutIfNeeded()

        if isFinished {
            // 근무완료1: 초기부터 isStopped = true → startAnimations 예약 자체 차단
            isStopped = true
            tooltipView.alpha    = 0
            tooltipView.isHidden = true
            snapToMaxHeightNow()
        } else {
            isStopped = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                guard let self, !self.isStopped else { return }
                self.startAnimations()
            }
        }
    }
    
    func updateAmount(_ amount: Int) {
        guard amount != currentAmount else { return }
        let old = formatted(currentAmount)
        let new = formatted(amount)
        currentAmount = amount
        if old.count == new.count {
            rollingLabel.rollTo(new)
        } else {
            rollingLabel.setText(new)
        }
        refreshTooltipIfNeeded()
    }
    
    func updateWorkingType(_ type: WorkingType) {
        UIView.transition(with: stackImageView, duration: 0.3, options: .transitionCrossDissolve) {
            self.stackImageView.image = type.stackImage
        }
    }
    
    // MARK: - Animations
    
    func startAnimations() {
        guard !isStopped else { return }
        isStopped = false
        startStackGrowth()
        scheduleTooltip()
    }
    
    /// 근무완료 1 진입 시 호출
    func stopAnimations() {
        isStopped = true
        stopStackGrowth()
        stopTooltip()
        tooltipView.layer.removeAllAnimations()
        tooltipView.alpha    = 0
        tooltipView.isHidden = true
        snapToMaxHeightNow()
    }
    
    private func snapToMaxHeightNow() {
        layoutIfNeeded()
        let h = stackContainer.bounds.height
        guard h > 0 else { return }
        let maxRatio = Constants.endHeightRatio
        stackBottomConstraint?.update(offset: h * (1 - maxRatio))
        updateFloatingContainerPosition(ratio: maxRatio)
        UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseOut) {
            self.layoutIfNeeded()
        }
    }
    
    // MARK: - Format
    
    private func formatted(_ amount: Int) -> String {
        AppNumberFormatter.decimalString(from: amount)
    }
    
    // MARK: - 30분 사이클 역산
    
    private func resolveCycleStart(from startedAt: Date) -> Date {
        let now          = Date()
        let totalElapsed = max(0, now.timeIntervalSince(startedAt))
        let cycleCount   = Int(totalElapsed / Constants.growthDuration)
        return startedAt.addingTimeInterval(Double(cycleCount) * Constants.growthDuration)
    }
    
    private func currentCycleRatio() -> CGFloat {
        guard let cycleStart = growthCycleStart else {
            return Constants.minHeightRatio
        }
        let elapsed  = max(0, Date().timeIntervalSince(cycleStart))
        let progress = min(CGFloat(elapsed) / CGFloat(Constants.growthDuration), 1.0)
        return Constants.minHeightRatio +
            (Constants.maxHeightRatio - Constants.minHeightRatio) * easeOutQuad(progress)
    }
    
    // MARK: - Tooltip
    
    private func refreshTooltipIfNeeded() {
        guard !isStopped else { return }
        let message = Self.tooltipMessage(for: currentAmount)
        guard message != lastTooltipMessage else { return }
        lastTooltipMessage = message
        guard let msg = message else { return }
        showTooltip(msg)
    }
    
    private func scheduleTooltip() {
        guard !isStopped else { return }
        stopTooltip()
        tooltipTimer = Timer.scheduledTimer(
            withTimeInterval: Constants.tooltipInterval,
            repeats: false
        ) { [weak self] _ in
            guard let self, !self.isStopped,
                  let msg = Self.tooltipMessage(for: self.currentAmount) else { return }
            self.showTooltip(msg)
        }
    }
    
    private func showTooltip(_ message: String) {
        guard !isStopped else { return }
        stopTooltip()
        tooltipView.isHidden = false
        tooltipView.alpha    = 0
        tooltipView.configure(text: message)

        UIView.animate(withDuration: 0.3) {
            self.tooltipView.alpha = 1
        } completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + Constants.tooltipDisplay) { [weak self] in
                guard let self, !self.isStopped else { return }
                UIView.animate(withDuration: 0.3) {
                    self.tooltipView.alpha = 0
                } completion: { _ in
                    self.scheduleTooltip()
                }
            }
        }
    }
    
    private func stopTooltip() {
        tooltipTimer?.invalidate()
        tooltipTimer = nil
    }
    
    // MARK: - Stack Growth
    
    private func startStackGrowth() {
        stopStackGrowth()
        growthDisplayLink = CADisplayLink(target: self, selector: #selector(updateStackPosition))
        growthDisplayLink?.add(to: .main, forMode: .common)
    }
    
    private func stopStackGrowth() {
        growthDisplayLink?.invalidate()
        growthDisplayLink = nil
    }
    
    @objc private func updateStackPosition() {
        guard !isStopped, let cycleStart = growthCycleStart else { return }
        let elapsed = Date().timeIntervalSince(cycleStart)
        if elapsed >= Constants.growthDuration { growthCycleStart = Date() }
        let ratio = currentCycleRatio()
        let h     = stackContainer.bounds.height
        guard h > 0 else { return }
        stackBottomConstraint?.update(offset: h * (1 - ratio))
        updateFloatingContainerPosition(ratio: ratio)
    }
    
    private func updateFloatingContainerPosition(ratio: CGFloat) {
        let h = stackContainer.bounds.height
        guard h > 0 else { return }
        floatingContainerBottomConstraint?.update(offset: -(h * ratio) - 20)
    }
    
    private func easeOutQuad(_ t: CGFloat) -> CGFloat { t * (2 - t) }
}
