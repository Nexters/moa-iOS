//
//  CommaNumberTextFieldFormatter.swift
//  Moa
//
//  Created by mirim on 2/6/26.
//

import UIKit

final class CommaNumberTextFieldFormatter: NSObject {
    private weak var textField: UITextField?

    private let formatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.groupingSeparator = ","
        f.maximumFractionDigits = 0
        return f
    }()
    
    private var maxDigits: Int?
    
    init(textField: UITextField, maxDigits: Int? = nil) {
        self.textField = textField
        self.maxDigits = maxDigits
        super.init()
        
        textField.keyboardType = .numberPad
    }
    
    func updateMaxDigits(_ maxDigits: Int?) {
        self.maxDigits = maxDigits
        reformatNow()
    }
    
    var rawDigits: String { (textField?.text ?? "").filter(\.isNumber) }
    var rawInt: Int? { Int(rawDigits) }
    
    /// salaryType 바뀌거나 외부에서 강제 갱신할 때 사용
    func reformatNow() {
        editingChanged()
    }
    
    @objc private func editingChanged() {
        guard let tf = textField else { return }
        if tf.markedTextRange != nil { return }
        
        let oldText = tf.text ?? ""
        let oldCursor = tf.selectedTextRange
        
        // 숫자만 + 최대 자리수 제한(콤마 제외)
        var digits = oldText.filter(\.isNumber)
        if let maxDigits, digits.count > maxDigits {
            digits = String(digits.prefix(maxDigits))
        }
        
        let newText: String
        if digits.isEmpty {
            newText = ""
        } else {
            let number = NSDecimalNumber(string: digits)
            newText = formatter.string(from: number) ?? digits
        }
        
        if oldText == newText { return }
        
        // 커서 보정용
        let digitsBeforeCursor = countDigitsBeforeCursor(in: tf, cursor: oldCursor)

        tf.text = newText

        // 포맷 후 커서 위치 복원
        tf.selectedTextRange = positionByDigitsCount(in: tf, formattedText: newText, digitsBeforeCursor: digitsBeforeCursor)
    }
    
    private func countDigitsBeforeCursor(
        in tf: UITextField,
        cursor: UITextRange?
    ) -> Int {
        guard let cursor,
              let range = tf.textRange(from: tf.beginningOfDocument, to: cursor.start)
        else {
            return (tf.text ?? "").filter(\.isNumber).count
        }

        let prefix = tf.text(in: range) ?? ""
        return prefix.filter(\.isNumber).count
    }

    private func positionByDigitsCount(
        in tf: UITextField,
        formattedText: String,
        digitsBeforeCursor: Int
    ) -> UITextRange? {
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
        
        if digitsBeforeCursor == 0 { targetIndex = 0 }
        
        guard let pos = tf.position(from: tf.beginningOfDocument, offset: targetIndex) else { return nil }
        return tf.textRange(from: pos, to: pos)
    }
}
