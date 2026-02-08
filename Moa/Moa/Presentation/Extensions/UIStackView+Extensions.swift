//
//  UIStackView+Extensions.swift
//  Moa
//
//  Created by mirim on 2/1/26.
//

import UIKit

extension UIStackView {
    func addArrangedSubViews(_ views: [UIView]) {
        views.forEach { addArrangedSubview($0) }
    }
}
