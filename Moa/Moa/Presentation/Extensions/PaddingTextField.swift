//
//  PaddingTextField.swift
//  Moa
//
//  Created by mirim on 2/1/26.
//

import UIKit

final class PaddingTextField: UITextField {
    var textInsets: UIEdgeInsets = .zero
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: textInsets)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: textInsets)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: textInsets)
    }
}
