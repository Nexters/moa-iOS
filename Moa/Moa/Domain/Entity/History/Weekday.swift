//
//  Weekday.swift
//  Moa
//
//  Created by mirim on 2/6/26.
//

import Foundation

enum Weekday: Int, CaseIterable {
    case mon = 1, tue, wed, thu, fri, sat, sun
    
    /// 월~일 정렬 보장
    static let ordered: [Weekday] = [.mon, .tue, .wed, .thu, .fri, .sat, .sun]
}
