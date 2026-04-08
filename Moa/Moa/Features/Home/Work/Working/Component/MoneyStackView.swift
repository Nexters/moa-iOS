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
        /// 고점 간격 — workStartedAt + N * peakInterval 이 N번째 고점 시각
        static let peakInterval: TimeInterval        = 30 * 60
        /// 고점 도달 후 유지 시간
        static let peakHoldDuration: TimeInterval    = 2.0
        /// 하강 시간
        static let dropDuration: TimeInterval        = 1.2
        /// peakHold + drop 이후 다음 growing 시작까지의 오프셋
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

    private let rollingLabel: RollingAmountLabel = {
        let label = RollingAmountLabel(animationDuration: 0.2)
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

    /// 근무 시작 절대 시각
    /// N번째 고점 시각 = workStartedAt + N * peakInterval  (N = 1, 2, 3 ...)
    private var workStartedAt: Date = Date()

    /// 현재 사이클 인덱스 (1-based: 첫 고점 = index 1)
    /// 현재 growing 중인 목표 고점 시각 = workStartedAt + peakIndex * peakInterval
    private var peakIndex: Int = 1

    /// 현재 growing 시작 시각
    /// - 첫 사이클: workStartedAt (이미 경과분 반영)
    /// - 이후 사이클: 이전 drop 완료 시각
    private var growingStartDate: Date = Date()

    /// 현재 growing 종료(= 고점) 시각
    /// = workStartedAt + peakIndex * peakInterval
    private var peakDate: Date = Date()

    /// growing 시작 시점의 ratio (이전 사이클 drop 완료 = minHeightRatio)
    private var growingStartRatio: CGFloat = Constants.minHeightRatio

    /// drop 시작 시각
    private var dropStartDate: Date = Date()

    /// drop 시작 시점의 ratio
    private var dropStartRatio: CGFloat = Constants.maxHeightRatio

    /// 마지막으로 렌더링된 ratio
    private var lastRenderedRatio: CGFloat = Constants.minHeightRatio

    private var displayLink: CADisplayLink?
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
            $0.height.equalToSuperview().multipliedBy(0.5)
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

        rollingLabel.setText(formatted(amount))
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
    //
    // 타임라인 (workStartedAt 기준):
    //
    //   고점 시각(N) = workStartedAt + N * peakInterval  (N = 1, 2, 3...)
    //
    //   ┌── growing ──┬── peakHold ──┬── dropping ──┬── growing ──┬ ...
    //   0s           10s            12s           13.2s          20s
    //
    //   현재 시각이 어느 구간에 있는지 역산해서 페이즈와 ratio를 결정.
    //   growing 시작 시각(growingStartDate)과 목표 고점 시각(peakDate)을
    //   정확히 세팅하면 tick()은 항상 올바른 위치를 계산함.

    private func resolveCurrentPhaseAndRatio() {
        let now              = Date()
        let peakInterval     = Constants.peakInterval
        let peakHoldDuration = Constants.peakHoldDuration
        let dropDuration     = Constants.dropDuration
        let postPeakDuration = Constants.postPeakDuration

        // 가장 최근 고점 시각을 역산
        // 예) startedAt=9:00, now=9:00:25 → 최근 고점 = 9:00:20 (N=2)
        let totalElapsed        = max(0, now.timeIntervalSince(workStartedAt))
        let latestPeakIndex     = max(1, Int(totalElapsed / peakInterval))
        let latestPeakDate      = workStartedAt.addingTimeInterval(Double(latestPeakIndex) * peakInterval)

        // 최근 고점 이후 경과 시간
        let elapsedSinceLatestPeak = now.timeIntervalSince(latestPeakDate)

        if elapsedSinceLatestPeak < 0 {
            // ── 아직 첫 고점 전 → Growing ──
            // now < latestPeakDate: 현재 growing 중
            peakIndex        = latestPeakIndex
            peakDate         = latestPeakDate

            // growing 시작 시각: 이전 drop 완료 시각
            // 첫 사이클이면 workStartedAt, 이후면 (N-1)번째 고점 + postPeak
            let previousDropEndDate: Date
            if latestPeakIndex == 1 {
                previousDropEndDate = workStartedAt
            } else {
                let previousPeakDate = workStartedAt.addingTimeInterval(Double(latestPeakIndex - 1) * peakInterval)
                previousDropEndDate  = previousPeakDate.addingTimeInterval(postPeakDuration)
            }

            growingStartDate  = previousDropEndDate
            growingStartRatio = Constants.minHeightRatio

            // 현재 growing 진행률 계산
            let growingDuration = peakDate.timeIntervalSince(growingStartDate)
            let growingElapsed  = now.timeIntervalSince(growingStartDate)
            let growingProgress = CGFloat(max(0, min(growingElapsed / growingDuration, 1.0)))
            lastRenderedRatio   = Constants.minHeightRatio
                + (Constants.maxHeightRatio - Constants.minHeightRatio)
                * easeOutCubic(growingProgress)
            currentPhase = .growing

        } else if elapsedSinceLatestPeak < peakHoldDuration {
            // ── PeakHold 구간 ──
            peakIndex         = latestPeakIndex
            peakDate          = latestPeakDate
            lastRenderedRatio = Constants.maxHeightRatio
            currentPhase      = .peakHold

        } else if elapsedSinceLatestPeak < postPeakDuration {
            // ── Dropping 구간 (중간 진입) ──
            peakIndex = latestPeakIndex
            peakDate  = latestPeakDate

            let dropElapsed  = elapsedSinceLatestPeak - peakHoldDuration
            let dropProgress = CGFloat(min(dropElapsed / dropDuration, 1.0))
            let currentRatio = Constants.maxHeightRatio
                + (Constants.minHeightRatio - Constants.maxHeightRatio)
                * easeInOutCubic(dropProgress)

            // dropStartDate 역산: tick()이 이 시각부터 경과 시간 계산
            dropStartDate     = now.addingTimeInterval(-dropElapsed)
            dropStartRatio    = Constants.maxHeightRatio
            lastRenderedRatio = currentRatio
            currentPhase      = .dropping

        } else {
            // ── drop 완료 후 다음 growing 시작 ──
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
        let oldFormatted = formatted(currentAmount)
        let newFormatted = formatted(amount)
        currentAmount = amount
        if oldFormatted.count == newFormatted.count { rollingLabel.rollTo(newFormatted) }
        else                                        { rollingLabel.setText(newFormatted) }
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
    //
    // 고점 시각(peakDate) = workStartedAt + peakIndex * peakInterval
    // 모든 구간 계산은 절대 시각 기준이므로 오차 누적 없음

    @objc private func tick() {
        guard !isStopped else { return }

        let now              = Date()
        let peakHoldDuration = Constants.peakHoldDuration
        let dropDuration     = Constants.dropDuration

        switch currentPhase {

        // ── Growing ──────────────────────────────────────────────
        case .growing:
            if now >= peakDate {
                // 정확히 고점 도달
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

        // ── PeakHold ─────────────────────────────────────────────
        case .peakHold:
            let elapsedSincePeak = now.timeIntervalSince(peakDate)
            if elapsedSincePeak >= peakHoldDuration {
                dropStartDate  = now
                dropStartRatio = lastRenderedRatio
                currentPhase   = .dropping
            }
            // 위치 고정

        // ── Dropping ─────────────────────────────────────────────
        case .dropping:
            let dropElapsed  = now.timeIntervalSince(dropStartDate)
            let dropProgress = CGFloat(min(dropElapsed / dropDuration, 1.0))
            let ratio        = dropStartRatio
                + (Constants.minHeightRatio - dropStartRatio)
                * easeInOutCubic(dropProgress)
            applyPosition(ratio: ratio)

            if dropProgress >= 1.0 {
                // drop 완료 → 다음 사이클 growing 시작
                applyPosition(ratio: Constants.minHeightRatio)

                peakIndex       += 1
                peakDate         = workStartedAt.addingTimeInterval(Double(peakIndex) * Constants.peakInterval)
                growingStartDate = now
                growingStartRatio = Constants.minHeightRatio
                currentPhase     = .growing
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
        let inversedProgress = progress - 1
        return inversedProgress * inversedProgress * inversedProgress + 1
    }

    private func easeInOutCubic(_ progress: CGFloat) -> CGFloat {
        if progress < 0.5 { return 4 * progress * progress * progress }
        let inversedProgress = -2 * progress + 2
        return 1 - inversedProgress * inversedProgress * inversedProgress / 2
    }

    // MARK: - Helpers

    private func formatted(_ amount: Int) -> String {
        AppNumberFormatter.decimalString(from: amount)
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

        // 메시지가 없거나 빈 문자열이면 표시하지 않고 다음으로 넘어감
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
