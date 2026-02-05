//
//  OnboardingCoordinator.swift
//  Moa
//
//  Created by mirim on 2/1/26.
//

import UIKit

final class OnboardingCoordinator {
    enum Step {
        case nickname
        case workPlace
        case salary
        case workPolicy
    }
    
    private let finish: () -> Void
    private weak var nav: UINavigationController?
    
    init(finish: @escaping () -> Void) {
        self.finish = finish
    }
    
    func start(from parentNav: UINavigationController, animated: Bool) {
        self.nav = parentNav
        parentNav.pushViewController(make(step: .nickname), animated: animated)
    }
    
    private func make(step: Step) -> UIViewController {
        switch step {
        case .nickname:
            let vm = OnboardingNicknameViewModel()
            let vc = OnboardingNicknameViewController(
                viewModel: vm,
                onNext: { [weak self] in
                    self?.go(.workPlace)
                }
            )
            return vc
            
        case .workPlace:
            let vm = OnboardingWorkplaceViewModel()
            let vc = OnboardingWorkplaceViewController(
                viewModel: vm,
                onNext: { [weak self] in
                    self?.go(.salary)
                }
            )
            return vc
            
        case .salary:
            let vm = OnboardingSalaryViewModel()
            let vc = OnboardingSalaryViewController(
                viewModel: vm,
                onNext: { [weak self] in
                    self?.go(.workPolicy)
                }
            )
            return vc
            
        case .workPolicy:
            let vm = OnboardingWorkPolicyViewModel()
            let vc = OnboardingWorkPolicyViewController(
                viewModel: vm,
                onNext: { [weak self] in
                    self?.complete()
                }
            )
            return vc
        }
    }
    
    private func go(_ next: Step) {
        nav?.pushViewController(make(step: next), animated: true)
    }
    
    private func complete() {
        finish()
    }
}

// TODO: 파일 분리
final class CommaNumberTextFieldFormatter: NSObject {
    private weak var textField: UITextField?

    private let formatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.groupingSeparator = ","
        f.maximumFractionDigits = 0 // 정수만
        return f
    }()

    /// 최대 자릿수(콤마 제외). 필요 없으면 nil
    private let maxDigits: Int?

    init(textField: UITextField, maxDigits: Int? = nil) {
        self.textField = textField
        self.maxDigits = maxDigits
        super.init()

        textField.keyboardType = .numberPad
        textField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
    }

    @objc private func editingChanged() {
        guard let tf = textField else { return }
        // 조합 입력 중이면 건드리지 않기
        if tf.markedTextRange != nil { return }

        let oldText = tf.text ?? ""
        let oldCursor = tf.selectedTextRange

        // 1) 숫자만 남기기
        var digits = oldText.filter(\.isNumber)

        // 2) 자릿수 제한 (원하면)
        if let maxDigits, digits.count > maxDigits {
            digits = String(digits.prefix(maxDigits))
        }

        // 3) 숫자 -> 콤마 문자열
        let newText: String
        if digits.isEmpty {
            newText = ""
        } else {
            // Int 범위 넘어갈 수 있으면 Decimal/BigInt 고려 필요.
            let number = NSDecimalNumber(string: digits)
            newText = formatter.string(from: number) ?? digits
        }

        // 텍스트 변경이 없으면 패스
        if oldText == newText { return }

        // 4) 커서 위치 보정(“숫자 몇 개 뒤에 커서가 있었는지”를 유지)
        let digitsBeforeCursor = countDigitsBeforeCursor(in: tf, text: oldText, cursor: oldCursor)

        tf.text = newText

        let newCursorPosition = positionByDigitsCount(in: tf, formattedText: newText, digitsBeforeCursor: digitsBeforeCursor)
        tf.selectedTextRange = newCursorPosition
    }

    private func countDigitsBeforeCursor(in tf: UITextField, text: String, cursor: UITextRange?) -> Int {
        guard
            let cursor,
            let start = tf.beginningOfDocument as UITextPosition?,
            let range = tf.textRange(from: start, to: cursor.start)
        else { return text.filter(\.isNumber).count }

        let prefix = tf.text(in: range) ?? ""
        return prefix.filter(\.isNumber).count
    }

    private func positionByDigitsCount(in tf: UITextField, formattedText: String, digitsBeforeCursor: Int) -> UITextRange? {
        let chars = Array(formattedText)
        var digitsSeen = 0
        var targetIndex = chars.count

        for (i, ch) in chars.enumerated() {
            if ch.isNumber { digitsSeen += 1 }
            if digitsSeen >= digitsBeforeCursor {
                targetIndex = i + 1
                break
            }
        }

        let pos = tf.position(from: tf.beginningOfDocument, offset: targetIndex)
        if let pos { return tf.textRange(from: pos, to: pos) }
        return nil
    }

    /// 필요하면 “숫자 원본 값”을 외부에서 꺼낼 수 있게
    var rawDigits: String {
        (textField?.text ?? "").filter(\.isNumber)
    }

    var rawInt: Int? {
        Int(rawDigits)
    }
}
