//
//  RollingAmountLabel.swift
//  Moa
//
//  숫자가 변경될 때 바뀐 자릿수만 위→아래 슬라이드되는 슬롯머신 롤링 애니메이션.
//

import UIKit
import SnapKit

final class RollingAmountLabel: UIView {

    // MARK: - Config

    private let font: UIFont
    private let textColor: UIColor
    private let animationDuration: TimeInterval = 0.2
    private let digitDelay: TimeInterval = 0.008

    // MARK: - State

    private var digitContainers: [UIView] = []
    private var currentLabels: [UILabel] = []
    private var currentText: String = ""

    // MARK: - Layout

    private lazy var stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.alignment = .center
        sv.spacing = 0
        return sv
    }()

    // MARK: - Init

    init(
        font: UIFont = AppTypography.h1_700.font(),
        textColor: UIColor = AppColor.IconAndText.highEmphasis
    ) {
        // 숫자 흔들림 방지 (추천)
        self.font = UIFont.monospacedDigitSystemFont(
            ofSize: font.pointSize,
            weight: .bold
        )
        self.textColor = textColor
        super.init(frame: .zero)

        addSubview(stackView)
        stackView.snp.makeConstraints { $0.edges.equalToSuperview() }

        clipsToBounds = true
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Public

    func setText(_ text: String) {
        currentText = text
        rebuildColumns(text, animated: false)
    }

    func rollTo(_ text: String) {
        guard text != currentText else { return }

        let old = currentText
        currentText = text

        if old.count != text.count {
            rebuildColumns(text, animated: true)
        } else {
            rollChangedDigits(from: old, to: text)
        }
    }

    // MARK: - Build

    private func rebuildColumns(_ text: String, animated: Bool) {

        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        digitContainers.removeAll()
        currentLabels.removeAll()

        for (index, char) in text.enumerated() {

            let label = makeLabel(String(char))
            let box = makeContainer(for: label)

            stackView.addArrangedSubview(box)
            digitContainers.append(box)
            currentLabels.append(label)

            if animated {
                label.transform = CGAffineTransform(
                    translationX: 0,
                    y: font.lineHeight
                )

                UIView.animate(
                    withDuration: animationDuration,
                    delay: Double(index) * digitDelay,
                    options: .curveEaseOut,
                    animations: {
                        label.transform = .identity
                    }
                )
            }
        }
    }

    private func makeContainer(for label: UILabel) -> UIView {
        let box = UIView()
        box.clipsToBounds = true

        box.addSubview(label)
        label.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        let size = label.intrinsicContentSize

        box.snp.makeConstraints {
            $0.width.equalTo(size.width)
            $0.height.equalTo(font.lineHeight)
        }

        return box
    }

    private func makeLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.font = font
        label.textColor = textColor
        label.text = text
        label.textAlignment = .center
        return label
    }

    // MARK: - Roll

    private func rollChangedDigits(from old: String, to new: String) {

        let oldArr = Array(old)
        let newArr = Array(new)

        for i in 0..<min(oldArr.count, newArr.count) {

            guard oldArr[i] != newArr[i],
                  i < digitContainers.count else { continue }

            let box = digitContainers[i]
            let oldLabel = currentLabels[i]
            let newLabel = makeLabel(String(newArr[i]))

            box.addSubview(newLabel)

            newLabel.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }

            let offset = font.lineHeight

            newLabel.transform = CGAffineTransform(
                translationX: 0,
                y: offset
            )

            UIView.animate(
                withDuration: animationDuration,
                delay: Double(i) * digitDelay,
                options: .curveEaseOut,
                animations: {
                    newLabel.transform = .identity
                    oldLabel.transform = CGAffineTransform(
                        translationX: 0,
                        y: -offset
                    )
                },
                completion: { [weak self] _ in
                    oldLabel.removeFromSuperview()
                    self?.currentLabels[i] = newLabel
                }
            )
        }
    }
}
