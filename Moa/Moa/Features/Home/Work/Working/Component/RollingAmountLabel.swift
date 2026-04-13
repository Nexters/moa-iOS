//
//  RollingAmountLabel.swift
//  Moa
//

import UIKit
import SnapKit

final class RollingAmountLabel: UIView {

    // MARK: - Config

    private let font:              UIFont
    private let textColor:         UIColor
    private let animationDuration: TimeInterval
    private let unit:              String?

    // MARK: - State

    private var currentValue:    Int    = 0
    private var currentText:     String = ""

    private var digitContainers: [UIView]  = []
    private var currentLabels:   [UILabel] = []
    private var animatingLabels: Set<UILabel> = []

    private let digitDelay: TimeInterval = 0

    // MARK: - Layout

    private lazy var stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis      = .horizontal
        sv.alignment = .center
        sv.spacing   = 0
        return sv
    }()

    // MARK: - Init

    /// - Parameters:
    ///   - font: 숫자 폰트 (기본: AppTypography.h1_700)
    ///   - textColor: 숫자 색상 (기본: highEmphasis)
    ///   - animationDuration: 한 자릿수 슬라이드 시간 (기본: 0.05)
    ///   - unit: 숫자 뒤에 붙는 단위 문자열. nil이면 단위 없음 (예: "원", "시간")
    init(
        font:              UIFont      = AppTypography.h1_700.font(),
        textColor:         UIColor     = AppColor.IconAndText.highEmphasis,
        animationDuration: TimeInterval = 0.05,
        unit:              String?     = nil
    ) {
        self.font = UIFont.monospacedDigitSystemFont(
            ofSize: font.pointSize,
            weight: .bold
        )
        self.textColor         = textColor
        self.animationDuration = animationDuration
        self.unit              = unit

        super.init(frame: .zero)

        addSubview(stackView)
        stackView.snp.makeConstraints { $0.edges.equalToSuperview() }
        clipsToBounds = true
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Public Interface

    /// 값을 설정합니다.
    /// - Parameters:
    ///   - amount: 표시할 정수 값
    ///   - animated: true면 롤링 애니메이션, false면 즉시 반영 (기본: true)
    func setValue(_ amount: Int, animated: Bool = true) {
        let newText = formatted(amount)
        currentValue = amount

        if animated {
            rollToText(newText)
        } else {
            setTextImmediate(newText)
        }
    }

    // MARK: - Internal Text Control (MoneyStackView 등 내부 호환용)

    /// 포매팅된 문자열을 직접 즉시 세팅 (내부 포매팅 우회가 필요한 경우)
    func setRawText(_ text: String) {
        setTextImmediate(text)
    }

    /// 포매팅된 문자열을 직접 롤링 (내부 포매팅 우회가 필요한 경우)
    func rollToRawText(_ text: String) {
        rollToText(text)
    }

    // MARK: - Formatting

    private func formatted(_ amount: Int) -> String {
        let number = AppNumberFormatter.decimalString(from: amount)
        if let unit { return "\(number)\(unit)" }
        return number
    }

    // MARK: - Private: Set Immediate

    private func setTextImmediate(_ text: String) {
        cancelAllAnimations()
        currentText = text
        rebuildColumns(text, animated: false)
    }

    // MARK: - Private: Roll

    private func rollToText(_ text: String) {
        guard text != currentText else { return }

        let old = currentText
        currentText = text

        if old.count != text.count {
            rebuildColumns(text, animated: true)
        } else {
            rollChangedDigits(from: old, to: text)
        }
    }

    // MARK: - Cancel

    private func cancelAllAnimations() {
        for label in animatingLabels {
            label.layer.removeAllAnimations()
            label.transform = .identity
        }
        animatingLabels.removeAll()
    }

    // MARK: - Rebuild (자릿수 변경 or 초기 세팅)

    private func rebuildColumns(_ text: String, animated: Bool) {
        cancelAllAnimations()

        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        digitContainers.removeAll()
        currentLabels.removeAll()

        for (index, char) in text.enumerated() {
            let label = makeLabel(String(char))
            let box   = makeContainer(label: label)

            stackView.addArrangedSubview(box)
            digitContainers.append(box)
            currentLabels.append(label)

            guard animated else { continue }

            box.layoutIfNeeded()

            let offset = font.lineHeight
            label.transform = CGAffineTransform(translationX: 0, y: offset)
            animatingLabels.insert(label)

            UIView.animate(
                withDuration: animationDuration,
                delay:        Double(index) * digitDelay,
                options:      [.curveEaseOut, .allowUserInteraction],
                animations: { label.transform = .identity },
                completion: { [weak self] finished in
                    guard let self else { return }
                    self.animatingLabels.remove(label)
                    if !finished { label.transform = .identity }
                }
            )
        }
    }

    // MARK: - Roll (자릿수 동일, 변경된 자리만)

    private func rollChangedDigits(from old: String, to new: String) {
        let oldArr = Array(old)
        let newArr = Array(new)
        let count  = min(oldArr.count, newArr.count)

        for i in 0..<count {
            guard oldArr[i] != newArr[i], i < digitContainers.count else { continue }

            let box      = digitContainers[i]
            let oldLabel = currentLabels[i]
            let newLabel = makeLabel(String(newArr[i]))

            if animatingLabels.contains(oldLabel) {
                if let presented = oldLabel.layer.presentation() {
                    oldLabel.layer.removeAllAnimations()
                    oldLabel.transform = CATransform3DGetAffineTransform(presented.transform)
                } else {
                    oldLabel.layer.removeAllAnimations()
                    oldLabel.transform = .identity
                }
                animatingLabels.remove(oldLabel)
            }

            box.addSubview(newLabel)
            newLabel.snp.makeConstraints { $0.edges.equalToSuperview() }
            box.layoutIfNeeded()

            let offset = font.lineHeight
            newLabel.transform = CGAffineTransform(translationX: 0, y: offset)
            animatingLabels.insert(newLabel)

            currentLabels[i] = newLabel

            let capturedOldLabel = oldLabel

            UIView.animate(
                withDuration: animationDuration,
                delay:        Double(i) * digitDelay,
                options:      [.curveEaseOut, .allowUserInteraction],
                animations: {
                    newLabel.transform         = .identity
                    capturedOldLabel.transform = CGAffineTransform(translationX: 0, y: -offset)
                },
                completion: { [weak self] finished in
                    guard let self else { return }
                    self.animatingLabels.remove(newLabel)
                    if !finished { newLabel.transform = .identity }
                    capturedOldLabel.layer.removeAllAnimations()
                    capturedOldLabel.removeFromSuperview()
                }
            )
        }
    }

    // MARK: - Factories

    private func makeContainer(label: UILabel) -> UIView {
        let box = UIView()
        box.clipsToBounds = true
        box.addSubview(label)

        label.sizeToFit()
        let labelWidth = ceil(label.bounds.width)

        label.snp.makeConstraints { $0.edges.equalToSuperview() }
        box.snp.makeConstraints {
            $0.width.equalTo(labelWidth)
            $0.height.equalTo(ceil(font.lineHeight))
        }

        return box
    }

    private func makeLabel(_ text: String) -> UILabel {
        let label           = UILabel()
        label.font          = font
        label.textColor     = textColor
        label.text          = text
        label.textAlignment = .center
        return label
    }
}
