//
//  RollingAmountLabel.swift
//  Moa
//
//  숫자가 변경될 때 바뀐 자릿수만 아래→위 슬라이드되는 슬롯머신 롤링 애니메이션.
//

import UIKit
import SnapKit

final class RollingAmountLabel: UIView {

    // MARK: - Config

    private let font:      UIFont
    private let textColor: UIColor

    static let rollingDuration: TimeInterval = 0.05
    
    var animationDuration: TimeInterval { Self.rollingDuration }

    private let digitDelay: TimeInterval = 0

    // MARK: - State

    private var digitContainers: [UIView]  = []
    private var currentLabels:   [UILabel] = []
    private var currentText:     String    = ""

    private var animatingLabels: Set<UILabel> = []

    // MARK: - Layout

    private lazy var stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis      = .horizontal
        sv.alignment = .center
        sv.spacing   = 0
        return sv
    }()

    // MARK: - Init

    init(
        font:      UIFont  = AppTypography.h1_700.font(),
        textColor: UIColor = AppColor.IconAndText.highEmphasis
    ) {
        // 모노스페이스 폰트 → 자릿수마다 너비 동일 → 레이아웃 안정
        self.font      = UIFont.monospacedDigitSystemFont(
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

    /// 애니메이션 없이 즉시 세팅 (초기값 / 리셋)
    func setText(_ text: String) {
        cancelAllAnimations()
        currentText = text
        rebuildColumns(text, animated: false)
    }

    /// 롤링 애니메이션으로 변경
    /// - 자릿수 동일: 변경된 자리만 위로 슬라이드
    /// - 자릿수 변경: 전체 재구성 + 슬라이드인 애니메이션
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
                animations: {
                    label.transform = .identity
                },
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

            // 이전 애니메이션이 진행 중이면 presentationLayer 기준으로 현재 위치 확정
            // → 잔상 없이 보이는 위치에서 자연스럽게 이어짐
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

            // 새 레이블: 아래서 올라옴
            newLabel.transform = CGAffineTransform(translationX: 0, y: offset)
            animatingLabels.insert(newLabel)

            // currentLabels 즉시 교체
            // → completion 전에 rollTo가 다시 불려도 올바른 oldLabel 참조 보장
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
