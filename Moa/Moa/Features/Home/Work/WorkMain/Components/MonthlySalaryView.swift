//
//  MonthlySalaryView.swift
//  Moa
//

import UIKit
import SnapKit

// MARK: - MonthlySalaryView

final class MonthlySalaryView: UIView {

    // MARK: - UI

    private let moneyImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let titleLabel: StyledLabel = {
        let label = StyledLabel()
        label.setText(
            "\(Date().month)월 누적 월급",
            style: .init(typography: AppTypography.t3_500, color: AppColor.IconAndText.highEmphasis)
        )
        label.textAlignment = .center
        return label
    }()

    private var rollingAmountLabel = RollingAmountLabel(
        font:      AppTypography.h1_700.font(),
        textColor: AppColor.IconAndText.highEmphasis
    )

    private let unitLabel: StyledLabel = {
        let label = StyledLabel()
        label.setText(
            "원",
            style: .init(typography: AppTypography.h3_500, color: AppColor.IconAndText.mediumEmphasis)
        )
        return label
    }()

    private lazy var amountStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [rollingAmountLabel, unitLabel])
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

    private var config: MonthlySalaryEntity?
    private var currentAmountColor: UIColor = AppColor.IconAndText.highEmphasis

    // MARK: - Animation State

    private var steps: [Int] = []
    private var currentStepIndex: Int = 0
    private var isAnimating = false

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    deinit { stopAnimation() }

    // MARK: - Layout

    private func setupUI() {
        addSubview(contentStack)
        contentStack.snp.makeConstraints { $0.edges.equalToSuperview() }
        moneyImageView.snp.makeConstraints { $0.size.equalTo(80) }
    }

    // MARK: - Configure

    func configure(_ config: MonthlySalaryEntity) {
        self.config = config

        moneyImageView.image = config.workStatus == .finished
            ? UIImage(resource: .Image.imgFullMoney)
            : config.type.moneyImg

        let newColor: UIColor = config.workStatus == .finished
            ? AppColor.IconAndText.green
            : config.type.amountLabelColor

        if newColor != currentAmountColor {
            currentAmountColor = newColor
            rebuildRollingLabel(color: newColor)
        }

        let overworked = config.workedEarnings > config.standardSalary
            && config.workStatus != .finished
        subtitleLabel.isHidden = !overworked
        if overworked {
            configureSubtitle(amount: config.workedEarnings, baseAmount: config.standardSalary)
        }

        startCounterAnimation(targetAmount: config.workedEarnings)
    }

    // MARK: - Private Helpers

    private func rebuildRollingLabel(color: UIColor) {
        let newLabel = RollingAmountLabel(
            font:      AppTypography.h1_700.font(),
            textColor: color
        )
        amountStack.removeArrangedSubview(rollingAmountLabel)
        rollingAmountLabel.removeFromSuperview()
        amountStack.insertArrangedSubview(newLabel, at: 0)
        rollingAmountLabel = newLabel
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
        AppNumberFormatter.decimalString(from: amount)
    }
}

// MARK: - Counter Animation

private extension MonthlySalaryView {

    func startCounterAnimation(targetAmount: Int) {
        stopAnimation()

        rollingAmountLabel.setText(formattedAmount(0))

        guard targetAmount > 0 else { return }

        let stepCount = 12
        steps = buildSmoothSteps(target: targetAmount, stepCount: stepCount)

        currentStepIndex = 0
        isAnimating = true

        animateNextStep()
    }
    
    private func animateNextStep() {
        guard isAnimating else { return }
        guard currentStepIndex < steps.count else {
            stopAnimation()
            return
        }

        let value = steps[currentStepIndex]
        currentStepIndex += 1

        let text = formattedAmount(value)

        rollingAmountLabel.rollTo(text)

        DispatchQueue.main.asyncAfter(
            deadline: .now() + rollingAmountLabel.animationDuration
        ) { [weak self] in
            self?.animateNextStep()
        }
    }
    
    private func buildSmoothSteps(target: Int, stepCount: Int) -> [Int] {
        var result: [Int] = []
        var last = -1

        for i in 0...stepCount {
            let t = Double(i) / Double(stepCount)

            let eased = 1 - pow(1 - t, 3)

            let value = Int(Double(target) * eased)

            if value != last {
                result.append(value)
                last = value
            }
        }

        if result.last != target {
            result.append(target)
        }

        return result
    }
    
    
    func stopAnimation() {
        isAnimating = false
    }
}
