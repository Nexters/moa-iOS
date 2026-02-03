//
//  MonthlySalaryView.swift
//  Moa
//
//  Created by 정도현 on 2/1/26.
//

import UIKit
import SnapKit

/// 월 별로 누적 월급 현황을 보여줍니다.
final class MonthlySalaryView: UIView {

    // MARK: - UI Components
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "\(month)월 누적 월급"
        label.textColor = AppColor.IconAndText.highEmphasis
        label.font = AppTypography.t3_500.font()
        label.textAlignment = .center
        return label
    }()

    private lazy var amountLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppColor.IconAndText.green
        label.font = AppTypography.h1_700.font()
        label.text = "0"
        return label
    }()

    private lazy var unitLabel: UILabel = {
        let label = UILabel()
        label.text = "원"
        label.textColor = AppColor.IconAndText.mediumEmphasis
        label.font = AppTypography.h3_500.font()
        return label
    }()

    private lazy var amountStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [amountLabel, unitLabel])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 4
        return stack
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = AppColor.IconAndText.mediumEmphasis
        label.font = AppTypography.b1_400.font()
        return label
    }()

    // MARK: - Data

    private let month: Int
    private let targetAmount: Int
    private let baseAmount: Int
    private let shouldAnimate: Bool

    // MARK: - Animation State

    private var displayLink: CADisplayLink?
    private var animationStartTime: CFAbsoluteTime = 0
    private let animationDuration: CGFloat = 1.5

    // MARK: - Init

    init(
        month: Int,
        amount: Int,
        baseAmount: Int,
        shouldAnimate: Bool
    ) {
        self.month = month
        self.targetAmount = amount
        self.baseAmount = baseAmount
        self.shouldAnimate = shouldAnimate

        super.init(frame: .zero)

        setupUI()
        configureSubtitle()
        configureAmount()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Setup UI

    private func setupUI() {
        addSubview(titleLabel)
        addSubview(amountStackView)
        addSubview(subtitleLabel)

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
        }

        amountStackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.centerX.equalToSuperview()
        }

        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(amountStackView.snp.bottom).offset(4)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }

    // MARK: - Helpers
    private func configureAmount() {
        if shouldAnimate {
            startCounterAnimation()
        } else {
            amountLabel.text = AppNumberFormatter.decimalString(from: targetAmount)
            subtitleLabel.alpha = 1
        }
    }

    private func configureSubtitle() {
        let diff = targetAmount - baseAmount
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let diffFormatted = formatter.string(from: NSNumber(value: diff)) ?? "\(diff)"

        let fullText = "기본 월급보다 +\(diffFormatted)원 더 일했어요"
        let attributed = NSMutableAttributedString(string: fullText)

        let grayColor = UIColor(white: 0.6, alpha: 1)
        attributed.addAttribute(
            .foregroundColor,
            value: grayColor,
            range: NSRange(fullText.startIndex..., in: fullText)
        )

        let greenPart = "+\(diffFormatted)원"
        if let range = fullText.range(of: greenPart) {
            attributed.addAttribute(
                .foregroundColor,
                value: AppColor.IconAndText.highEmphasis,
                range: NSRange(range, in: fullText)
            )
        }

        subtitleLabel.attributedText = attributed
    }
}

// MARK: - Counter Rolling Animatio'
private extension MonthlySalaryView {

    func startCounterAnimation() {
        amountLabel.text = "0"
        subtitleLabel.alpha = 0

        animationStartTime = CACurrentMediaTime()

        displayLink?.invalidate()
        displayLink = CADisplayLink(target: self, selector: #selector(updateCounter))
        displayLink?.add(to: .main, forMode: .common)
    }

    @objc
    private func updateCounter() {
        let elapsed = CACurrentMediaTime() - animationStartTime
        var progress = CGFloat(elapsed) / animationDuration
        progress = min(progress, 1.0)

        let easedProgress = progress * (2 - progress)
        let currentValue = Int(CGFloat(targetAmount) * easedProgress)

        amountLabel.text = AppNumberFormatter.decimalString(from: currentValue)

        if progress >= 1.0 {
            displayLink?.invalidate()
            displayLink = nil
            amountLabel.text = AppNumberFormatter.decimalString(from: targetAmount)

            UIView.animate(withDuration: 0.4, delay: 0.2) {
                self.subtitleLabel.alpha = 1
            }
        }
    }
}
