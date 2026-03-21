//
//  Date+Extensions.swift
//  Moa
//
//  Created by 정도현 on 3/17/26.
//

import Foundation

extension Date {
 
    /// KST 기준 연도
    var year: Int {
        Calendar.korea.component(.year, from: self)
    }
 
    /// KST 기준 월
    var month: Int {
        Calendar.korea.component(.month, from: self)
    }
 
    /// KST 기준 일
    var day: Int {
        Calendar.korea.component(.day, from: self)
    }
 
    /// KST 기준 "yyyy-MM-dd" 문자열 — API 날짜 파라미터에 사용
    var dateString: String {
        DateFormatter.yyyyMMdd.string(from: self)
    }
 
    /// KST 기준 현재 시각을 분(minute) 단위로 환산 — clockIn/Out 비교에 사용
    var minutesFromMidnight: Int {
        let c = Calendar.korea.dateComponents([.hour, .minute], from: self)
        return (c.hour ?? 0) * 60 + (c.minute ?? 0)
    }
    
    /// "yyyy년 M월 d일" 문자열 (UI 표시용)
    var koreanDateString: String {
        DateFormatter.koreanDateLong.string(from: self)
    }
 
    /// KST 기준 오늘 날짜에 지정 시:분을 덮어쓴 Date 반환
    /// - clockIn / clockOut startedAt 계산에 사용
    static func todayAt(hour: Int, minute: Int) -> Date {
        var c = Calendar.korea.dateComponents([.year, .month, .day], from: Date())
        c.hour   = hour
        c.minute = minute
        c.second = 0
        return Calendar.korea.date(from: c) ?? Date()
    }
    
}
