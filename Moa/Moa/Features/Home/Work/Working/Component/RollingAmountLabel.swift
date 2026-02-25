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

    private let font: UIFont
    private let textColor: UIColor
    private let animationDuration: TimeInterval = 0.22
    private let digitDelay: TimeInterval = 0.008

    // MARK: - State

    private var digitContainers: [UIView]  = []
    private var currentLabels:   [UILabel] = []
    private var currentText:     String    = ""

    /// 현재 애니메이션 진행 중인 레이블 추적
    /// completion에서 이 Set에 없는 레이블은 이미 교체된 것이므로 무시
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
        font: UIFont       = AppTypography.h1_700.font(),
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

    /// 애니메이션 없이 즉시 세팅 (초기값)
    func setText(_ text: String) {
        cancelAllAnimations()
        currentText = text
        rebuildColumns(text, animated: false)
    }

    /// 롤링 애니메이션으로 변경
    func rollTo(_ text: String) {
        guard text != currentText else { return }

        let old = currentText
        currentText = text

        if old.count != text.count {
            // 자릿수 변경 → 전체 재구성
            rebuildColumns(text, animated: true)
        } else {
            // 자릿수 동일 → 바뀐 자리만 롤
            rollChangedDigits(from: old, to: text)
        }
    }

    // MARK: - Cancel

    /// 진행 중인 모든 애니메이션 즉시 취소
    private func cancelAllAnimations() {
        // 진행 중 레이블들을 확정 위치로 스냅
        for label in animatingLabels {
            label.layer.removeAllAnimations()
            label.transform = .identity
        }
        animatingLabels.removeAll()
    }

    // MARK: - Rebuild (자릿수 변경 or 초기 세팅)

    private func rebuildColumns(_ text: String, animated: Bool) {
        // 이전 애니메이션 전부 취소 후 잔재 제거
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

            // 레이아웃 확정 후 transform 적용 (위치 틀어짐 방지)
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
                    // 완료 안된 경우(취소됨) transform 정리
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

            // ── 핵심 수정 ──────────────────────────────────────────────────
            // 이전 애니메이션이 진행 중이면 oldLabel의 현재 표시 위치를
            // presentationLayer 기준으로 확정한 뒤 애니메이션 제거
            // → 잔상 없이 현재 보이는 위치에서 자연스럽게 이어짐
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
            // ────────────────────────────────────────────────────────────────

            // 새 레이블을 box에 추가하고 레이아웃 확정
            box.addSubview(newLabel)
            newLabel.snp.makeConstraints { $0.edges.equalToSuperview() }
            box.layoutIfNeeded()

            let offset = font.lineHeight

            // 새 레이블: 아래서 올라옴
            newLabel.transform = CGAffineTransform(translationX: 0, y: offset)
            animatingLabels.insert(newLabel)

            // currentLabels를 즉시 교체
            // → completion 전에 rollTo가 또 불려도 올바른 oldLabel 참조 보장
            currentLabels[i] = newLabel

            let capturedOldLabel = oldLabel

            UIView.animate(
                withDuration: animationDuration,
                delay:        Double(i) * digitDelay,
                options:      [.curveEaseOut, .allowUserInteraction],
                animations: {
                    newLabel.transform = .identity
                    capturedOldLabel.transform = CGAffineTransform(translationX: 0, y: -offset)
                },
                completion: { [weak self] finished in
                    guard let self else { return }
                    // newLabel 애니메이션 종료 처리
                    self.animatingLabels.remove(newLabel)
                    if !finished { newLabel.transform = .identity }

                    // oldLabel 완전 제거 (잔상 원천 차단)
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

        // intrinsicContentSize 대신 sizeToFit 후 bounds 사용 → 레이아웃 패스 전 안전
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
        let label        = UILabel()
        label.font       = font
        label.textColor  = textColor
        label.text       = text
        label.textAlignment = .center
        return label
    }
}
