//
//  TextSanitizer.swift
//  Moa
//
//  Created by mirim on 2/18/26.
//

import Foundation

enum TextSanitizer {
    static func sanitizeKoreanEnglishNoSpaces(_ input: String) -> String {
        let noSpaces = input.replacingOccurrences(of: "\\s+", with: "", options: .regularExpression)
        let normalized = noSpaces.replacingOccurrences(
            of: "[^a-zA-Z가-힣ㄱ-ㅎㅏ-ㅣ]",
            with: "",
            options: .regularExpression
        )
        return normalized
    }
    
    static func isAllowedKoreanEnglishOnly(_ input: String) -> Bool {
        guard !input.isEmpty else { return true }
        let allowedPattern = "[^a-zA-Z가-힣ㄱ-ㅎㅏ-ㅣ]"
        return input.range(of: allowedPattern, options: .regularExpression) != nil
    }
}

