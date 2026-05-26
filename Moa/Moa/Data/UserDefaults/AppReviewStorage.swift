//
//  AppReviewStorage.swift
//  Moa
//

import Foundation

// MARK: - AppReviewStorage
//
// 앱 리뷰 관련 상태를 UserDefaults에 저장
// - review_requested: 리뷰를 한 번 요청한 이후 설정 화면 CTA 숨김 + 트리거 재발동 방지
// - review_home_visit_count: 홈 화면 방문 횟수 (3회 이상 시 트리거)
// - review_last_payday_date: 월급일 트리거 중복 방지용 날짜

enum AppReviewStorage {

    private enum Key {
        static let requested        = "review_requested"
        static let homeVisitCount   = "review_home_visit_count"
        static let lastPaydayDate   = "review_last_payday_date"
    }

    // MARK: - Requested

    /// 리뷰 요청 완료로 표시
    static func markRequested() {
        UserDefaults.standard.set(true, forKey: Key.requested)
    }

    /// 사용자가 이미 리뷰 요청을 했는지 여부
    static var isRequested: Bool {
        UserDefaults.standard.bool(forKey: Key.requested)
    }

    // MARK: - Home Visit Count

    /// 홈 화면 방문 횟수 1 증가
    static func incrementHomeVisitCount() {
        UserDefaults.standard.set(homeVisitCount + 1, forKey: Key.homeVisitCount)
    }

    /// 현재까지 홈 화면 방문 횟수
    static var homeVisitCount: Int {
        UserDefaults.standard.integer(forKey: Key.homeVisitCount)
    }

    // MARK: - Payday

    /// 오늘 날짜를 월급일 리뷰 노출 완료로 표시
    static func markPaydayReviewShownToday() {
        UserDefaults.standard.set(Date().dateString, forKey: Key.lastPaydayDate)
    }

    /// 오늘 이미 월급일 리뷰를 노출했는지 여부
    static var hasShownPaydayReviewToday: Bool {
        UserDefaults.standard.string(forKey: Key.lastPaydayDate) == Date().dateString
    }

    // MARK: - Reset

    /// 로그아웃 / 회원탈퇴 시 전체 초기화
    static func reset() {
        UserDefaults.standard.removeObject(forKey: Key.requested)
        UserDefaults.standard.removeObject(forKey: Key.homeVisitCount)
        UserDefaults.standard.removeObject(forKey: Key.lastPaydayDate)
    }
}
