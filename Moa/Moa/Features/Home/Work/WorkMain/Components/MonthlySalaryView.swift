//
//  MonthlySalaryView.swift
//  Moa
//
//  Created by 정도현 on 2/1/26.
//

import UIKit
import SnapKit

// MARK: - MonthlySalaryViewConfig
// HomeDisplayData에서 필요한 정보만 추출해 뷰로 전달하는 DTO

struct MonthlySalaryViewConfig {
    let month: Int
    let amount: Int
    let baseAmount: Int
    let scheduleType: HomeScheduleStatus    // HomeWorkScheduleType → HomeScheduleStatus로 변경
    let shouldAnimate: Bool
}

// MARK: - MonthlySalaryView

final class MonthlySalaryView: UIView {

    // MARK: - UI

    private let moneyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleLabel: StyledLabel = {
        let label = StyledLabel()
        label.textAlignment = .center
        return label
    }()

    private let amountLabel: StyledLabel = {
        let label = StyledLabel()
        label.textAlignment = .right
        return label
    }()

    private let unitLabel: StyledLabel = {
        let label = StyledLabel()
        label.setText(
            "원",
            style: .init(typography: AppTypography.h3_500, color: AppColor.IconAndText.mediumEmphasis)
        )
        return label
    }()

    private lazy var amountStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [amountLabel, unitLabel])
        stack.axis      = .horizontal
        stack.alignment = .center
        stack.spacing   = 4
        return stack
    }()

    private let subtitleLabel: StyledLabel = {
        let label = StyledLabel()
        label.setStyle(.init(
            typography: AppTypography.b1_400,
            color: AppColor.IconAndText.mediumEmphasis
        ))
        label.textAlignment = .center
        return label
    }()

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            moneyImageView, titleLabel, amountStack, subtitleLabel
        ])
        stack.axis      = .vertical
        stack.alignment = .center
        stack.setCustomSpacing(24, after: moneyImageView)
        stack.setCustomSpacing(0,  after: titleLabel)
        stack.setCustomSpacing(4,  after: amountStack)
        return stack
    }()

    // MARK: - State

    private var config: MonthlySalaryViewConfig?

    // MARK: - Animation

    private var displayLink: CADisplayLink?
    private var animationStartTime: CFAbsoluteTime = 0
    private let animationDuration: CGFloat = 1.5

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    deinit { displayLink?.invalidate() }

    // MARK: - Layout

    private func setupUI() {
        addSubview(contentStack)
        contentStack.snp.makeConstraints { $0.edges.equalToSuperview() }
        moneyImageView.snp.makeConstraints { $0.size.equalTo(80) }
    }

    // MARK: - Configure

    func configure(_ config: MonthlySalaryViewConfig) {
        self.config = config

        moneyImageView.image = config.scheduleType.moneyImage

        titleLabel.setText(
            "\(config.month)월 누적 월급",
            style: .init(typography: AppTypography.t3_500, color: AppColor.IconAndText.highEmphasis)
        )
        amountLabel.setStyle(.init(
            typography: AppTypography.h1_700,
            color: config.scheduleType.accentColor
        ))

        subtitleLabel.isHidden = !config.scheduleType.showsWageDescription
        if config.scheduleType.showsWageDescription {
            configureSubtitle(amount: config.amount, baseAmount: config.baseAmount)
        }

        configureAmount(amount: config.amount, shouldAnimate: config.shouldAnimate)
    }

    // MARK: - Private

    private func configureAmount(amount: Int, shouldAnimate: Bool) {
        displayLink?.invalidate()
        displayLink = nil

        if shouldAnimate {
            startCounterAnimation(targetAmount: amount)
        } else {
            amountLabel.setText(formattedAmount(amount))
            if config?.scheduleType.showsWageDescription == true { subtitleLabel.alpha = 1 }
        }
    }

    private func configureSubtitle(amount: Int, baseAmount: Int) {
        let diff          = amount - baseAmount
        let diffFormatted = AppNumberFormatter.decimalString(from: diff)
        let fullText      = "기본 월급보다 +\(diffFormatted)원 더 일했어요"
        let emphasisPart  = "+\(diffFormatted)원"

        let attributed = NSMutableAttributedString(string: fullText)
        attributed.addAttribute(
            .foregroundColor,
            value: AppColor.IconAndText.mediumEmphasis,
            range: NSRange(location: 0, length: fullText.count)
        )
        if let range = fullText.range(of: emphasisPart) {
            attributed.addAttribute(
                .foregroundColor,
                value: AppColor.IconAndText.highEmphasis,
                range: NSRange(range, in: fullText)
            )
        }
        subtitleLabel.attributedText = attributed
    }

    private func formattedAmount(_ amount: Int) -> String {
        let base = AppNumberFormatter.decimalString(from: amount)
        return config?.scheduleType == .afterWork ? "+ \(base)" : base
    }
}

// MARK: - Counter Animation

private extension MonthlySalaryView {

    func startCounterAnimation(targetAmount: Int) {
        amountLabel.setText(formattedAmount(0))
        if config?.scheduleType.showsWageDescription == true { subtitleLabel.alpha = 0 }

        animationStartTime = CACurrentMediaTime()
        displayLink = CADisplayLink(target: self, selector: #selector(updateCounter))
        displayLink?.add(to: .main, forMode: .common)
    }

    @objc func updateCounter() {
        guard let config else { return }

        let elapsed  = CACurrentMediaTime() - animationStartTime
        let progress = min(CGFloat(elapsed) / animationDuration, 1.0)
        let eased    = progress * (2 - progress)
        let current  = Int(CGFloat(config.amount) * eased)

        amountLabel.setText(formattedAmount(current))

        guard progress >= 1.0 else { return }
        displayLink?.invalidate()
        displayLink = nil
        amountLabel.setText(formattedAmount(config.amount))

        if config.scheduleType.showsWageDescription {
            UIView.animate(withDuration: 0.4, delay: 0.2) { self.subtitleLabel.alpha = 1 }
        }
    }
}
