//
//  StyledLabel.swift
//  Moa
//
//  Created by mirim on 1/26/26.
//

import UIKit

final class StyledLabel: UILabel {

    // MARK: - Style

    var textStyle: TextStyle? {
        didSet { reapplyStyle() }
    }

    // MARK: - Overrides

    override var text: String? {
        didSet { reapplyStyle() }
    }

    override var textAlignment: NSTextAlignment {
        didSet { reapplyStyle() }
    }

    // MARK: - Private

    private func reapplyStyle() {
        guard let style = textStyle else { return }
        let content = text ?? ""
        attributedText = style.makeAttributedString(content, alignment: textAlignment)
    }
}
