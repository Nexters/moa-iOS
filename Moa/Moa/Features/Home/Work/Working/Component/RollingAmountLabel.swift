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
    private let animationDuration: TimeInterval = 0.20
    private let digitDelay: TimeInterval        = 0.008   // 자릿수마다 살짝 딜레이

    // MARK: - State

    private var digitContainers: [UIView]  = []
    private var currentLabels: [UILabel]   = []
    private var currentText: String        = ""

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
        font: UIFont       = AppTypography.h1_700.font(),
        textColor: UIColor = AppColor.IconAndText.highEmphasis
    ) {
        self.font      = font
        self.textColor = textColor
        super.init(frame: .zero)
        
        addSubview(stackView)
        
        stackView.snp.makeConstraints { $0.edges.equalToSuperview() }
        clipsToBounds = true
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Public

    /// 애니메이션 없이 즉시 세팅 (초기값·자릿수 변경 시)
    func setText(_ text: String) {
        currentText = text
        buildColumns(text, animated: false)
    }

    /// 롤링 애니메이션으로 교체
    /// - 자릿수(글자수) 동일: 변경된 칸만 롤링
    /// - 자릿수 다름: 전체 리빌드 (천 단위 쉼표 구조 변경)
    func rollTo(_ text: String) {
        guard text != currentText else { return }
        let old = currentText
        currentText = text

        if old.count != text.count {
            buildColumns(text, animated: true)
        } else {
            rollChangedDigits(from: old, to: text)
        }
    }

    // MARK: - Private

    private func charSize(_ str: String) -> CGSize {
        let attrs: [NSAttributedString.Key: Any] = [.font: font]
        let s = (str as NSString).size(withAttributes: attrs)
        return CGSize(width: ceil(s.width) + 1, height: ceil(s.height))
    }

    private func makeLabel(_ text: String) -> UILabel {
        let l = UILabel()
        l.font          = font
        l.textColor     = textColor
        l.text          = text
        l.textAlignment = .center
        l.setContentHuggingPriority(.required, for: .horizontal)
        l.setContentCompressionResistancePriority(.required, for: .horizontal)
        return l
    }

    // MARK: Build

    /// 전체 컬럼 리빌드 (글자 수 변경 / 초기 세팅)
    private func buildColumns(_ text: String, animated: Bool) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        digitContainers.removeAll()
        currentLabels.removeAll()

        for (i, ch) in text.enumerated() {
            let str  = String(ch)
            let sz   = charSize(str)
            let lbl  = makeLabel(str)

            let box = UIView()
            box.clipsToBounds = true
            box.snp.makeConstraints { $0.size.equalTo(sz) }
            box.addSubview(lbl)
            lbl.snp.makeConstraints { $0.center.equalToSuperview() }

            stackView.addArrangedSubview(box)
            digitContainers.append(box)
            currentLabels.append(lbl)

            if animated {
                lbl.transform = CGAffineTransform(translationX: 0, y: -sz.height)
                UIView.animate(
                    withDuration: animationDuration,
                    delay: Double(i) * digitDelay,
                    options: .curveEaseOut,
                    animations: { lbl.transform = .identity },
                    completion: nil
                )
            }
        }
    }

    // MARK: Roll

    /// 변경된 자릿수만 롤링 (글자 수 동일할 때)
    private func rollChangedDigits(from old: String, to new: String) {
        let oldArr = Array(old)
        let newArr = Array(new)

        for i in 0..<min(oldArr.count, newArr.count) {
            guard oldArr[i] != newArr[i], i < digitContainers.count else { continue }

            let box      = digitContainers[i]
            let oldLabel = currentLabels[i]
            let newStr   = String(newArr[i])
            let newLabel = makeLabel(newStr)
            let h        = box.bounds.height > 0 ? box.bounds.height : charSize(newStr).height

            box.addSubview(newLabel)
            newLabel.snp.makeConstraints { $0.center.equalToSuperview() }
            newLabel.transform = CGAffineTransform(translationX: 0, y: -h) // 위에서 대기

            UIView.animate(
                withDuration: animationDuration,
                delay: Double(i) * digitDelay,           // 자릿수별 순차 딜레이
                options: .curveEaseOut,
                animations: {
                    newLabel.transform = .identity
                    oldLabel.transform = CGAffineTransform(translationX: 0, y: h)
                },
                completion: { [weak self] _ in
                    oldLabel.removeFromSuperview()
                    guard let self, i < self.currentLabels.count else { return }
                    self.currentLabels[i] = newLabel
                }
            )
        }
    }
}
