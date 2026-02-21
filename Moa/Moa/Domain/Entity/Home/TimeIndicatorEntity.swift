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
    
    var totalMinutes: Int { hour * 60 + minute }
}

extension TimeIndicatorEntity {
    /// "HH:mm" 형식의 문자열을 TimeIndicatorEntity로 변환 (예: "09:00" -> TimeIndicatorEntity(hour: 9, minute: 0))
    init?(from string: String?) {
        guard let string else { return nil }
        let parts = string.split(separator: ":")
        guard parts.count == 2,
              let hour = Int(parts[0]),
              let minute = Int(parts[1]),
              (0..<24).contains(hour),
              (0..<60).contains(minute)
        else {
            return nil
        }
        self.init(hour: hour, minute: minute)
    }
}
