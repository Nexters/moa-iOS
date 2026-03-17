//
//  Calendar+Extensions.swift
//  Moa
//
//  Created by 정도현 on 3/17/26.
//

import Foundation

extension Calendar {
 
    /// 한국 표준시(KST, Asia/Seoul) 기준 그레고리력 캘린더
    static var korea: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Seoul")!
        return calendar
    }
}
