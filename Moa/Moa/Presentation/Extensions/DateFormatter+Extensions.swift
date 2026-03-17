//
//  DateFormatter+Extensions.swift
//  Moa
//
//  Created by 정도현 on 3/17/26.
//

import Foundation

extension DateFormatter {
 
    /// "yyyy-MM-dd" 포맷 (KST)
    static let yyyyMMdd: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale     = Locale(identifier: "ko_KR")
        formatter.timeZone   = TimeZone(identifier: "Asia/Seoul")
        return formatter
    }()
}
