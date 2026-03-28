//
//  MoaUserDefaults.swift
//  Moa
//
//  Created by 정도현 on 3/28/26.
//

import Foundation

// MARK: - WorkConfirmStorage
//
// 근무완료 상태에서 "완료" 버튼을 탭했을 때 해당 날짜 저장

enum WorkConfirmStorage {
    
    private static let key = "work.confirmed.date"
    
    /// 오늘 날짜로 확인 완료 저장
    static func markConfirmedToday() {
        UserDefaults.standard.set(Date().dateString, forKey: key)
    }
    
    /// 오늘 이미 확인했는지 여부
    static var isConfirmedToday: Bool {
        UserDefaults.standard.string(forKey: key) == Date().dateString
    }
    
    /// 저장된 확인 날짜 초기화 (테스트 / 자정 갱신용)
    static func reset() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
