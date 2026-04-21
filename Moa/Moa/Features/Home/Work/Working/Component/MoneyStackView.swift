//
//  EarningsStackView.swift
//  Moa
//

import UIKit
import SnapKit
import Lottie

final class EarningsStackView: UIView {

    // MARK: - Constants

    private enum Constants {
        static let peakInterval: TimeInterval        = 30 * 60
        static let peakHoldDuration: TimeInterval    = 2.0
        static let dropDuration: TimeInterval        = 1.2
        static var postPeakDuration: TimeInterval    { peakHoldDuration + dropDuration }

        static let minHeightRatio: CGFloat           = 0.30
        static let maxHeightRatio: CGFloat           = 0.78
        static let endHeightRatio: CGFloat           = 0.9

        static let tooltipFadeIn:  TimeInterval      = 0.3
        static let tooltipDisplay: TimeInterval      = 5.0
        static let tooltipFadeOut: TimeInterval      = 0.3
        static let tooltipGap:     TimeInterval      = 2.0
        static let tooltipInitialDelay: TimeInterval = 0.5

        static let solidMaskHeight: CGFloat          = 90
        static let gradientMaskHeight: CGFloat       = 60
    }

    // MARK: - Phase

    private enum Phase {
        case growing
        case peakHold
        case dropping
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

    // animationDuration 0.2s — 1초 tick 간격 안에서 충분히 완료되는 속도
    private let rollingLabel = RollingAmountLabel(animationDuration: 0.2)

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
        let stackView = UIStackView(arrangedSubviews: [rollingLabel, unitLabel])
        stackView.axis      = .horizontal
        stackView.alignment = .center
        stackView.spacing   = 2
        return stackView
    }()

    private let stackContainer = UIView()

    private let stackImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode     = .scaleAspectFit
        imageView.backgroundColor = .clear
        return imageView
    }()

    private let maskGradientLayer = CAGradientLayer()

    private lazy var confetiView: LottieAnimationView = {
        let animationView = LottieAnimationView(name: "confeti")
        animationView.contentMode              = .scaleAspectFill
        animationView.loopMode                 = .playOnce
        animationView.isUserInteractionEnabled = false
        animationView.alpha                    = 0
        animationView.layer.zPosition          = 999
        return animationView
    }()

    // MARK: - Animation State

    private var isStopped = false
    private var currentPhase: Phase = .growing

    private var workStartedAt:    Date    = Date()
    private var peakIndex:        Int     = 1
    private var growingStartDate: Date    = Date()
    private var peakDate:         Date    = Date()
    private var growingStartRatio: CGFloat = Constants.minHeightRatio
    private var dropStartDate:    Date    = Date()
    private var dropStartRatio:   CGFloat = Constants.maxHeightRatio
    private var lastRenderedRatio: CGFloat = Constants.minHeightRatio
    private var displayLink:      CADisplayLink?
    private var hasAppliedInitialPosition = false

    // MARK: - Tooltip State

    private var tooltipTimer:     Timer?
    private var currentAmount:    Int = 0
    private var tooltipContext:   TooltipContextEntity?
    private var tooltipKindIndex: Int = 0
    private let tooltipKinds          = TooltipType.allCases

    // MARK: - Layout Constraints

    private var stackBottomConstraint:             Constraint?
    private var floatingContainerBottomConstraint: Constraint?

    // MARK: - Init

    init(workingType: WorkingType) {
        super.init(frame: .zero)
        stackImageView.image = workingType.stackImage
        setupUI()
        setupMask()
    }

    required init?(coder: NSCoder) { fatalError() }
    deinit { stopAnimations() }

    // MARK: - layoutSubviews

    override func layoutSubviews() {
        super.layoutSubviews()
        if !hasAppliedInitialPosition, stackContainer.bounds.height > 0 {
            hasAppliedInitialPosition = true
            applyPosition(ratio: lastRenderedRatio)
        }
        updateMaskLayout()
    }

    // MARK: - Setup

    private func setupUI() {
        floatingInfoContainer.addSubViews([tooltipView, titleLabel, amountRow])
        addSubViews([stackContainer, confetiView])

        confetiView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalToSuperview()
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
        let totalHeight = bounds.height
        guard totalHeight > 0 else { return }
        maskGradientLayer.frame = bounds

        let solidHeight    = Constants.solidMaskHeight
        let gradientHeight = Constants.gradientMaskHeight
        let solidStart     = 1 - (solidHeight / totalHeight)
        let gradientStart  = 1 - ((solidHeight + gradientHeight) / totalHeight)

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

    func configure(
        amount: Int,
        startedAt: Date,
        isFinished: Bool = false,
        context: TooltipContextEntity? = nil
    ) {
        currentAmount    = amount
        tooltipContext   = context
        tooltipKindIndex = 0
        workStartedAt    = startedAt

        // 즉시 값 세팅 (애니메이션 없이)
        rollingLabel.setValue(amount, animated: false)
        layoutIfNeeded()

        if isFinished {
            isStopped            = true
            tooltipView.alpha    = 0
            tooltipView.isHidden = true
            titleLabel.setText("오늘 쌓은 월급", style: .init(
                typography: AppTypography.t3_500,
                color: AppColor.IconAndText.highEmphasis
            ))
            snapToEndHeightAnimated()
        } else {
            isStopped = false
            titleLabel.setText("오늘 쌓은 월급", style: .init(
                typography: AppTypography.b1_400,
                color: AppColor.IconAndText.mediumEmphasis
            ))

            resolveCurrentPhaseAndRatio()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                guard let self, !self.isStopped else { return }
                self.startDisplayLink()
                self.scheduleNextTooltip(delay: Constants.tooltipInitialDelay)
            }
        }
    }

    // MARK: - Phase Resolution

    private func resolveCurrentPhaseAndRatio() {
        let now              = Date()
        let peakInterval     = Constants.peakInterval
        let peakHoldDuration = Constants.peakHoldDuration
        let dropDuration     = Constants.dropDuration
        let postPeakDuration = Constants.postPeakDuration

        let totalElapsed        = max(0, now.timeIntervalSince(workStartedAt))
        let latestPeakIndex     = max(1, Int(totalElapsed / peakInterval))
        let latestPeakDate      = workStartedAt.addingTimeInterval(Double(latestPeakIndex) * peakInterval)
        let elapsedSinceLatestPeak = now.timeIntervalSince(latestPeakDate)

        if elapsedSinceLatestPeak < 0 {
            peakIndex = latestPeakIndex
            peakDate  = latestPeakDate

            let previousDropEndDate: Date
            if latestPeakIndex == 1 {
                previousDropEndDate = workStartedAt
            } else {
                let previousPeakDate = workStartedAt.addingTimeInterval(Double(latestPeakIndex - 1) * peakInterval)
                previousDropEndDate  = previousPeakDate.addingTimeInterval(postPeakDuration)
            }

            growingStartDate  = previousDropEndDate
            growingStartRatio = Constants.minHeightRatio

            let growingDuration = peakDate.timeIntervalSince(growingStartDate)
            let growingElapsed  = now.timeIntervalSince(growingStartDate)
            let growingProgress = CGFloat(max(0, min(growingElapsed / growingDuration, 1.0)))
            lastRenderedRatio   = Constants.minHeightRatio
                + (Constants.maxHeightRatio - Constants.minHeightRatio)
                * easeOutCubic(growingProgress)
            currentPhase = .growing

        } else if elapsedSinceLatestPeak < peakHoldDuration {
            peakIndex         = latestPeakIndex
            peakDate          = latestPeakDate
            lastRenderedRatio = Constants.maxHeightRatio
            currentPhase      = .peakHold

        } else if elapsedSinceLatestPeak < postPeakDuration {
            peakIndex = latestPeakIndex
            peakDate  = latestPeakDate

            let dropElapsed  = elapsedSinceLatestPeak - peakHoldDuration
            let dropProgress = CGFloat(min(dropElapsed / dropDuration, 1.0))
            let currentRatio = Constants.maxHeightRatio
                + (Constants.minHeightRatio - Constants.maxHeightRatio)
                * easeInOutCubic(dropProgress)

            dropStartDate     = now.addingTimeInterval(-dropElapsed)
            dropStartRatio    = Constants.maxHeightRatio
            lastRenderedRatio = currentRatio
            currentPhase      = .dropping

        } else {
            peakIndex = latestPeakIndex + 1
            peakDate  = workStartedAt.addingTimeInterval(Double(peakIndex) * peakInterval)

            let previousDropEndDate = latestPeakDate.addingTimeInterval(postPeakDuration)
            growingStartDate        = previousDropEndDate
            growingStartRatio       = Constants.minHeightRatio

            let growingDuration = peakDate.timeIntervalSince(growingStartDate)
            let growingElapsed  = now.timeIntervalSince(growingStartDate)
            let growingProgress = CGFloat(max(0, min(growingElapsed / growingDuration, 1.0)))
            lastRenderedRatio   = Constants.minHeightRatio
                + (Constants.maxHeightRatio - Constants.minHeightRatio)
                * easeOutCubic(growingProgress)
            currentPhase = .growing
        }
    }

    // MARK: - Amount / Context Update

    func updateAmount(_ amount: Int) {
        guard amount != currentAmount else { return }
        currentAmount = amount
        // 자릿수 변화 여부에 관계없이 setValue가 내부에서 처리
        rollingLabel.setValue(amount, animated: true)
    }

    func updateContext(_ context: TooltipContextEntity) {
        tooltipContext = context
    }

    func updateWorkingType(_ workingType: WorkingType) {
        UIView.transition(with: stackImageView, duration: 0.3, options: .transitionCrossDissolve) {
            self.stackImageView.image = workingType.stackImage
        }
    }

    // MARK: - Public Animation Control

    func startAnimations() {
        guard !isStopped else { return }
        startDisplayLink()
        scheduleNextTooltip(delay: Constants.tooltipInitialDelay)
    }

    func stopAnimations() {
        isStopped = true
        stopDisplayLink()
        cancelTooltipTimer()
        tooltipView.layer.removeAllAnimations()
        tooltipView.alpha    = 0
        tooltipView.isHidden = true
        snapToEndHeightAnimated()
    }

    // MARK: - DisplayLink

    private func startDisplayLink() {
        stopDisplayLink()
        displayLink = CADisplayLink(target: self, selector: #selector(tick))
        displayLink?.add(to: .main, forMode: .common)
    }

    private func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }

    // MARK: - Tick

    @objc private func tick() {
        guard !isStopped else { return }

        let now              = Date()
        let peakHoldDuration = Constants.peakHoldDuration
        let dropDuration     = Constants.dropDuration

        switch currentPhase {

        case .growing:
            if now >= peakDate {
                applyPosition(ratio: Constants.maxHeightRatio)
                currentPhase = .peakHold
                playConfeti()
            } else {
                let growingDuration = peakDate.timeIntervalSince(growingStartDate)
                let growingElapsed  = now.timeIntervalSince(growingStartDate)
                let growingProgress = CGFloat(max(0, min(growingElapsed / growingDuration, 1.0)))
                let ratio           = growingStartRatio
                    + (Constants.maxHeightRatio - growingStartRatio)
                    * easeOutCubic(growingProgress)
                applyPosition(ratio: ratio)
            }

        case .peakHold:
            let elapsedSincePeak = now.timeIntervalSince(peakDate)
            if elapsedSincePeak >= peakHoldDuration {
                dropStartDate  = now
                dropStartRatio = lastRenderedRatio
                currentPhase   = .dropping
            }

        case .dropping:
            let dropElapsed  = now.timeIntervalSince(dropStartDate)
            let dropProgress = CGFloat(min(dropElapsed / dropDuration, 1.0))
            let ratio        = dropStartRatio
                + (Constants.minHeightRatio - dropStartRatio)
                * easeInOutCubic(dropProgress)
            applyPosition(ratio: ratio)

            if dropProgress >= 1.0 {
                applyPosition(ratio: Constants.minHeightRatio)
                peakIndex        += 1
                peakDate          = workStartedAt.addingTimeInterval(Double(peakIndex) * Constants.peakInterval)
                growingStartDate  = now
                growingStartRatio = Constants.minHeightRatio
                currentPhase      = .growing
            }
        }
    }

    // MARK: - Position Apply

    private func applyPosition(ratio: CGFloat) {
        let containerHeight = stackContainer.bounds.height
        guard containerHeight > 0 else { return }

        lastRenderedRatio = ratio
        stackBottomConstraint?.update(offset: containerHeight * (1 - ratio))
        floatingContainerBottomConstraint?.update(offset: -(containerHeight * ratio) - 20)
        stackContainer.layoutIfNeeded()
    }

    // MARK: - Snap (finished 상태)

    private func snapToEndHeightAnimated() {
        let containerHeight = stackContainer.bounds.height
        guard containerHeight > 0 else { return }
        stackBottomConstraint?.update(offset: containerHeight * (1 - Constants.endHeightRatio))
        floatingContainerBottomConstraint?.update(offset: -(containerHeight * Constants.endHeightRatio) - 20)
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut) {
            self.layoutIfNeeded()
        }
    }

    // MARK: - Easing

    private func easeOutCubic(_ progress: CGFloat) -> CGFloat {
        let p = progress - 1
        return p * p * p + 1
    }

    private func easeInOutCubic(_ progress: CGFloat) -> CGFloat {
        if progress < 0.5 { return 4 * progress * progress * progress }
        let p = -2 * progress + 2
        return 1 - p * p * p / 2
    }

    // MARK: - Tooltip Scheduling

    private func scheduleNextTooltip(delay: TimeInterval) {
        guard !isStopped else { return }
        cancelTooltipTimer()
        tooltipTimer = Timer.scheduledTimer(
            withTimeInterval: delay,
            repeats: false
        ) { [weak self] _ in
            guard let self, !self.isStopped else { return }
            self.showCurrentTooltip()
        }
    }

    private func showCurrentTooltip() {
        guard !isStopped, let context = tooltipContext else { return }

        guard let message = makeMessage(for: context), !message.isEmpty else {
            advanceTooltipKind()
            scheduleNextTooltip(delay: Constants.tooltipGap)
            return
        }

        tooltipView.isHidden = false
        tooltipView.alpha    = 0
        tooltipView.configure(text: message)

        UIView.animate(withDuration: Constants.tooltipFadeIn) {
            self.tooltipView.alpha = 1
        } completion: { [weak self] _ in
            guard let self, !self.isStopped else { return }

            self.tooltipTimer = Timer.scheduledTimer(
                withTimeInterval: Constants.tooltipDisplay,
                repeats: false
            ) { [weak self] _ in
                guard let self, !self.isStopped else { return }

                UIView.animate(withDuration: Constants.tooltipFadeOut) {
                    self.tooltipView.alpha = 0
                } completion: { [weak self] _ in
                    guard let self, !self.isStopped else { return }
                    self.tooltipView.isHidden = true
                    self.advanceTooltipKind()
                    self.scheduleNextTooltip(delay: Constants.tooltipGap)
                }
            }
        }
    }

    private func advanceTooltipKind() {
        tooltipKindIndex = (tooltipKindIndex + 1) % tooltipKinds.count
    }

    private func cancelTooltipTimer() {
        tooltipTimer?.invalidate()
        tooltipTimer = nil
    }

    // MARK: - Message Factory

    private func makeMessage(for context: TooltipContextEntity) -> String? {
        if context.workingType == .vacation {
            return "휴가 중이지만 월급은 쌓여요"
        }

        switch tooltipKinds[tooltipKindIndex] {
        case .monthlyGoal:
            let formattedAmount = AppNumberFormatter.decimalString(from: context.workedEarnings)
            return "이번달에 쌓은 월급 \(formattedAmount)원"
        case .buyable:
            guard let item = Self.buyableItem(for: currentAmount) else { return nil }
            return "지금까지 번 돈으로 \(item) 살 수 있어요"
        case .cheer:
            return cheerMessage(endTime: context.endTime)
        }
    }

    private func cheerMessage(endTime: TimeIndicatorEntity) -> String? {
        let dateComponents   = Calendar.current.dateComponents([.hour, .minute], from: Date())
        let nowTotalMinutes  = (dateComponents.hour ?? 0) * 60 + (dateComponents.minute ?? 0)
        let remainingMinutes = endTime.totalMinutes - nowTotalMinutes

        guard remainingMinutes >= 1 else { return nil }

        if remainingMinutes < 60 {
            return "화이팅! \(remainingMinutes)분 후 퇴근이에요"
        } else {
            let hours   = remainingMinutes / 60
            let minutes = remainingMinutes % 60
            return minutes == 0
                ? "화이팅! \(hours)시간 후 퇴근이에요"
                : "화이팅! \(hours)시간 \(minutes)분 후 퇴근이에요"
        }
    }
}

// MARK: - Lottie

private extension EarningsStackView {
    func playConfeti() {
        confetiView.stop()
        confetiView.alpha = 1
        confetiView.play { [weak self] _ in
            UIView.animate(withDuration: 0.5) {
                self?.confetiView.alpha = 0
            }
        }
    }
}
