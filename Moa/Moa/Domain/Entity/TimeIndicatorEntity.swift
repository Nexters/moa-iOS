//
//  TimeIndicatorEntity.swift
//  Moa
//
//  Created by 정도현 on 2/15/26.
//

import Foundation

/// 시간 데이터 모델
struct TimeIndicatorEntity: Equatable {
    let hour: Int
    let minute: Int
    
    /// "09:20" 형식의 문자열
    var displayString: String {
        return String(format: "%02d:%02d", hour, minute)
    }
    
    /// TimeComponents 생성
    static func from(hour: Int, minute: Int) -> TimeIndicatorEntity {
        return TimeIndicatorEntity(hour: hour, minute: minute)
    }
}
