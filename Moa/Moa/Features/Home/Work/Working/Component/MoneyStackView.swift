//
//  MoneyStackView.swift
//  Moa
//

import UIKit
import SnapKit
import Lottie

final class EarningsStackView: UIView {
    
    // MARK: - Constants
    
    private enum Constants {
        static let minHeightRatio: CGFloat         = 0.30
        static let maxHeightRatio: CGFloat         = 0.70
        static let endHeightRatio: CGFloat         = 0.84
        static let growthDuration: TimeInterval    = 30 * 60
        
        static let tooltipFadeIn:  TimeInterval    = 0.3
        static let tooltipDisplay: TimeInterval    = 5.0
        static let tooltipFadeOut: TimeInterval    = 0.3
        static let tooltipGap:     TimeInterval    = 2.0
        static let tooltipInitialDelay: TimeInterval = 0.5
        
        static let solidMaskHeight: CGFloat        = 90
        static let gradientMaskHeight: CGFloat     = 60
    }
    
    // MARK: - Buyable Thresholds
    
    private static let buyableThresholds: [(minAmount: Int, item: String)] = [
        (10_000,  "커피와 조각 케이크를"),
        (20_000,  "치킨 한 마리를"),
        (30_000,  "영화 2인 예매를"),
        (50_000,  "로지텍 무선 마우스를"),
        (100_000, "나이키 운동화 한 켤레를"),
        (200_000, "노스페이스 백팩을"),
        (250_000, "갤럭시 워치 FE를"),
        (300_000, "에어팟 3세대를"),
        (350_000, "아이패드 9세대를"),
        (400_000, "다이슨 무선 청소기를"),
        (450_000, "닌텐도 스위치를"),
        (500_000, "플레이스테이션 5를"),
    ]
    
    private static func buyableItem(for amount: Int) -> String? {
        buyableThresholds.last(where: { amount >= $0.minAmount })?.item
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
    
    private let rollingLabel: RollingAmountLabel = {
        let label = RollingAmountLabel()
        label.transform = CGAffineTransform(translationX: 0, y: -2)
        return label
    }()
    
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
        sv.axis = .horizontal
        sv.alignment = .center
        sv.spacing = 2
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
    
    private lazy var confetiView: LottieAnimationView = {
        let view = LottieAnimationView(name: "confeti")
        view.contentMode = .scaleAspectFill
        view.loopMode = .playOnce
        view.isUserInteractionEnabled = false
        view.alpha = 0
        view.layer.zPosition = 999
        return view
    }()
    
    // MARK: - State
    
    private var isStopped = false
    
    private var stackBottomConstraint: Constraint?
    private var floatingContainerBottomConstraint: Constraint?
    private var growthCycleStart: Date?
    private var growthDisplayLink: CADisplayLink?
    private var hasAppliedInitialPosition = false
    
    private var tooltipTimer: Timer?
    private var currentAmount: Int      = 0
    private var tooltipContext: TooltipContextEntity?
    
    /// Work 3종 롤링 현재 인덱스
    private var tooltipKindIndex: Int   = 0
    private let tooltipKinds            = TooltipType.allCases
    
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
        addSubViews([stackContainer, confetiView])
        
        confetiView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        
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
    
    /// - Parameters:
    ///   - isFinished: 근무완료1이면 true → 말풍선·성장 완전 차단
    ///   - context:    말풍선 문구 생성용 컨텍스트 (nil이면 말풍선 없음)
    func configure(
        amount: Int,
        startedAt: Date,
        isFinished: Bool = false,
        context: TooltipContextEntity? = nil
    ) {
        currentAmount    = amount
        tooltipContext   = context
        growthCycleStart = resolveCycleStart(from: startedAt)
        tooltipKindIndex = 0
        
        rollingLabel.setText(formatted(amount))
        layoutIfNeeded()
        
        if isFinished {
            // configure 시점에 isStopped = true → asyncAfter 예약이 실행돼도 guard에서 차단
            isStopped            = true
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
        if old.count == new.count { rollingLabel.rollTo(new) }
        else                      { rollingLabel.setText(new) }
    }
    
    /// tick마다 퇴근까지 남은 시간이 변하므로 context 갱신
    func updateContext(_ context: TooltipContextEntity) {
        tooltipContext = context
    }
    
    func updateWorkingType(_ type: WorkingType) {
        UIView.transition(with: stackImageView, duration: 0.3, options: .transitionCrossDissolve) {
            self.stackImageView.image = type.stackImage
        }
    }
    
    // MARK: - Animations
    
    func startAnimations() {
        guard !isStopped else { return }
        startStackGrowth()
        scheduleNextTooltip(delay: Constants.tooltipInitialDelay)
    }
    
    func stopAnimations() {
        isStopped = true
        stopStackGrowth()
        cancelTooltipTimer()
        tooltipView.layer.removeAllAnimations()
        tooltipView.alpha    = 0
        tooltipView.isHidden = true
        snapToMaxHeightNow()
    }
    
    private func snapToMaxHeightNow() {
        layoutIfNeeded()
        let h = stackContainer.bounds.height
        guard h > 0 else { return }
        stackBottomConstraint?.update(offset: h * (1 - Constants.endHeightRatio))
        updateFloatingContainerPosition(ratio: Constants.endHeightRatio)
        UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseOut) {
            self.layoutIfNeeded()
        }
    }
    
    // MARK: - Tooltip Scheduling
    
    private func scheduleNextTooltip(delay: TimeInterval) {
        guard !isStopped else { return }
        cancelTooltipTimer()
        tooltipTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            guard let self, !self.isStopped else { return }
            self.showCurrentTooltip()
        }
    }
    
    private func showCurrentTooltip() {
        guard !isStopped, let context = tooltipContext else { return }
        
        // 메시지 생성 불가(buyable 미달 등) → 즉시 다음 종류로 스킵
        guard let message = makeMessage(for: context) else {
            advanceKind()
            scheduleNextTooltip(delay: 0.1)
            return
        }
        
        // ── 페이드 인 ──────────────────────────────────────────
        tooltipView.isHidden = false
        tooltipView.alpha    = 0
        tooltipView.configure(text: message)
        
        UIView.animate(withDuration: Constants.tooltipFadeIn) {
            self.tooltipView.alpha = 1
        } completion: { [weak self] _ in
            guard let self, !self.isStopped else { return }
            
            // ── display 유지 ──────────────────────────────────
            self.tooltipTimer = Timer.scheduledTimer(
                withTimeInterval: Constants.tooltipDisplay,
                repeats: false
            ) { [weak self] _ in
                guard let self, !self.isStopped else { return }
                
                // ── 페이드 아웃 → 다음 순서 ──────────────────────
                UIView.animate(withDuration: Constants.tooltipFadeOut) {
                    self.tooltipView.alpha = 0
                } completion: { [weak self] _ in
                    guard let self, !self.isStopped else { return }
                    self.advanceKind()
                    self.scheduleNextTooltip(delay: Constants.tooltipGap)
                }
            }
        }
    }
    
    /// Work 3종 인덱스 순환. 휴가는 단일이지만 호출돼도 무해
    private func advanceKind() {
        tooltipKindIndex = (tooltipKindIndex + 1) % tooltipKinds.count
    }
    
    private func cancelTooltipTimer() {
        tooltipTimer?.invalidate()
        tooltipTimer = nil
    }
    
    // MARK: - Message Factory
    
    private func makeMessage(for context: TooltipContextEntity) -> String? {
        // 휴가: 단일 문구 (advanceKind 호출돼도 같은 문구만 반복)
        if context.workingType == .vacation {
            return "휴가 중이지만 월급은 쌓여요"
        }
        
        // Work 3종 롤링
        switch tooltipKinds[tooltipKindIndex] {
            
        case .monthlyGoal:
            let amount = AppNumberFormatter.decimalString(from: context.workedEarnings)
            return "이번달에 쌓은 월급 \(amount)원"
            
        case .buyable:
            guard let item = Self.buyableItem(for: currentAmount) else { return nil }
            return "지금까지 번 돈으로 \(item) 살 수 있어요"
            
        case .cheer:
            return cheerMessage(endTime: context.endTime)
        }
    }
    
    private func cheerMessage(endTime: TimeIndicatorEntity) -> String? {
        let comps     = Calendar.current.dateComponents([.hour, .minute], from: Date())
        let nowMin    = (comps.hour ?? 0) * 60 + (comps.minute ?? 0)
        let remaining = endTime.totalMinutes - nowMin
        
        switch remaining {
        case ..<1:
            return nil
        case 1..<60:
            return "화이팅! \(remaining)분 후 퇴근이에요"
        default:
            let hours   = remaining / 60
            let minutes = remaining % 60
            return minutes == 0
            ? "화이팅! \(hours)시간 후 퇴근이에요"
            : "화이팅! \(hours)시간 \(minutes)분 후 퇴근이에요"
        }
    }
    
    // MARK: - Helpers
    
    private func formatted(_ amount: Int) -> String {
        AppNumberFormatter.decimalString(from: amount)
    }
    
    private func resolveCycleStart(from startedAt: Date) -> Date {
        let elapsed    = max(0, Date().timeIntervalSince(startedAt))
        let cycleCount = Int(elapsed / Constants.growthDuration)
        return startedAt.addingTimeInterval(Double(cycleCount) * Constants.growthDuration)
    }
    
    private func currentCycleRatio() -> CGFloat {
        guard let cycleStart = growthCycleStart else { return Constants.minHeightRatio }
        let elapsed  = max(0, Date().timeIntervalSince(cycleStart))
        let progress = min(CGFloat(elapsed) / CGFloat(Constants.growthDuration), 1.0)
        return Constants.minHeightRatio +
        (Constants.maxHeightRatio - Constants.minHeightRatio) * easeOutQuad(progress)
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

        if elapsed >= Constants.growthDuration {
            playConfeti()
            growthCycleStart = Date()
        }

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

// Lottie
private extension EarningsStackView {
    func playConfeti() {
        confetiView.alpha = 1

        confetiView.play { [weak self] _ in
            UIView.animate(withDuration: 0.3) {
                self?.confetiView.alpha = 0
            }
        }
    }
}
