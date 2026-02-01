//
//  UIView+Extensions.swift
//  Moa
//
//  Created by mirim on 2/1/26.
//

import UIKit

extension UIView {
    func addSubViews(_ views: [UIView]) {
        views.forEach { addSubview($0) }
    }
}
