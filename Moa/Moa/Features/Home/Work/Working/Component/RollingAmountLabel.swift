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

    private var currentValue: Int    = 0
    private var currentText:  String = ""

    /// 슬롯(자릿수) 배열
    private var slots: [Slot] = []

    // MARK: - Slot

    /// 각 자릿수 슬롯
    private struct Slot {
        let container:     UIView
        var activeLabel:   UILabel
        var pendingLabels: [UILabel] = []
    }

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
    ///   - animationDuration: 한 자릿수 슬라이드 시간 (기본: 0.05)
    ///   - unit: 숫자 뒤에 붙는 단위 문자열. nil이면 단위 없음 (예: "원", "시간")
    init(
        font:              UIFont       = AppTypography.h1_700.font(),
        textColor:         UIColor      = AppColor.IconAndText.highEmphasis,
        animationDuration: TimeInterval = 0.05,
        unit:              String?      = nil
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
        let newText  = formatted(amount)
        currentValue = amount

        if animated {
            rollToText(newText)
        } else {
            setTextImmediate(newText)
        }
    }

    // MARK: - Formatting

    private func formatted(_ amount: Int) -> String {
        let number = AppNumberFormatter.decimalString(from: amount)
        if let unit { return "\(number)\(unit)" }
        return number
    }

    // MARK: - Immediate

    private func setTextImmediate(_ text: String) {
        guard text != currentText else { return }
        currentText = text
        cancelAllPendingAndRebuild(text)
    }

    // MARK: - Roll

    private func rollToText(_ text: String) {
        guard text != currentText else { return }
        let old = currentText
        currentText = text

        if old.count != text.count {
            // 자릿수 변경: 전체 재구성
            cancelAllPendingAndRebuild(text, animated: true)
        } else {
            // 자릿수 동일: 변경된 슬롯만 롤링
            rollChangedSlots(from: old, to: text)
        }
    }

    // MARK: - Cancel All & Rebuild

    /// 모든 진행 중인 애니메이션을 즉시 종료하고 슬롯을 재구성합니다.
    private func cancelAllPendingAndRebuild(_ text: String, animated: Bool = false) {
        // 모든 슬롯의 pending 레이블 즉시 제거
        for slot in slots {
            for label in slot.pendingLabels {
                label.layer.removeAllAnimations()
                label.removeFromSuperview()
            }
            slot.activeLabel.layer.removeAllAnimations()
            slot.activeLabel.transform = .identity
        }
        slots.removeAll()
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        buildSlots(for: text, animated: animated)
    }

    // MARK: - Build Slots

    private func buildSlots(for text: String, animated: Bool) {
        for (index, char) in text.enumerated() {
            let label     = makeLabel(String(char))
            let container = makeContainer(label: label)
            let slot      = Slot(container: container, activeLabel: label)

            stackView.addArrangedSubview(container)
            slots.append(slot)

            guard animated else { continue }

            container.layoutIfNeeded()

            // 아래에서 위로 슬라이드인
            label.transform = CGAffineTransform(translationX: 0, y: font.lineHeight)

            UIView.animate(
                withDuration: animationDuration,
                delay:        0,
                options:      [.curveEaseOut, .allowUserInteraction],
                animations:   { label.transform = .identity },
                completion:   { finished in
                    if !finished { label.transform = .identity }
                }
            )

            _ = index  // delay 없이 동시 슬라이드
        }
    }

    // MARK: - Roll Changed Slots

    private func rollChangedSlots(from old: String, to new: String) {
        let oldArr = Array(old)
        let newArr = Array(new)
        let count  = min(oldArr.count, newArr.count)

        for i in 0..<count {
            guard oldArr[i] != newArr[i], i < slots.count else { continue }
            rollSlot(at: i, newChar: String(newArr[i]))
        }
    }

    private func rollSlot(at index: Int, newChar: String) {
        let container = slots[index].container
        let oldLabel  = slots[index].activeLabel

        slots[index].pendingLabels.append(oldLabel)
        slots[index].activeLabel = makeLabel(newChar)

        let newLabel = slots[index].activeLabel

        if let presented = oldLabel.layer.presentation() {
            oldLabel.layer.removeAllAnimations()
            oldLabel.layer.transform = presented.transform
        } else {
            oldLabel.layer.removeAllAnimations()
        }

        container.addSubview(newLabel)
        newLabel.snp.makeConstraints { $0.edges.equalToSuperview() }
        container.layoutIfNeeded()

        newLabel.transform = CGAffineTransform(translationX: 0, y: font.lineHeight)

        let offset       = font.lineHeight
        let capturedOld  = oldLabel

        UIView.animate(
            withDuration: animationDuration,
            delay:        0,
            options:      [.curveEaseOut, .allowUserInteraction],
            animations: {
                newLabel.transform    = .identity
                capturedOld.transform = CGAffineTransform(translationX: 0, y: -offset)
            },
            completion: { [weak self] finished in
                guard let self else { return }

                if !finished { newLabel.transform = .identity }

                // pending에서 완전히 제거
                capturedOld.layer.removeAllAnimations()
                capturedOld.removeFromSuperview()

                if let idx = self.slots[index].pendingLabels.firstIndex(of: capturedOld) {
                    self.slots[index].pendingLabels.remove(at: idx)
                }
            }
        )
    }

    // MARK: - Factories

    private func makeContainer(label: UILabel) -> UIView {
        let box = UIView()
        box.clipsToBounds = true   // 슬라이드 중 넘치는 부분을 잘라냄
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
