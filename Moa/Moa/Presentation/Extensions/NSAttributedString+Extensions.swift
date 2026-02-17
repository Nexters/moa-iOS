//
//  NSAttributedString+Extensions.swift
//  Moa
//
//  Created by mirim on 2/15/26.
//

import UIKit

extension NSAttributedString {
    static func styled(
        baseText: String,
        baseTypography: UIFont,
        baseColor: UIColor,
        highlights: [(substring: String, typography: UIFont, color: UIColor)]
    ) -> NSAttributedString {
        let full = NSMutableAttributedString(
            string: baseText,
            attributes: [
                .font: baseTypography,
                .foregroundColor: baseColor
            ]
        )

        for highlight in highlights {
            guard !highlight.substring.isEmpty else { continue }
            var searchRange = (baseText as NSString).range(of: baseText)
            while true {
                let found = (baseText as NSString).range(of: highlight.substring, options: [], range: searchRange)
                if found.location == NSNotFound { break }
                full.addAttributes(
                    [
                        .font: highlight.typography,
                        .foregroundColor: highlight.color
                    ],
                    range: found
                )
                let nextLocation = found.location + found.length
                let remainingLength = (baseText as NSString).length - nextLocation
                if remainingLength <= 0 { break }
                searchRange = NSRange(location: nextLocation, length: remainingLength)
            }
        }
        return full
    }
}
