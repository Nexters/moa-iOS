//
//  AppReviewStorage.swift
//  Moa
//

import Foundation

// MARK: - AppReviewStorage
//
// 사용자가 '서비스 의견 남기기' CTA를 탭했을 때 상태 저장
// 한 번 요청된 이후에는 해당 버튼을 노출하지 않음

enum AppReviewStorage {

    private static let key = "review_requested"

    /// 리뷰 요청 완료로 표시
    static func markRequested() {
        UserDefaults.standard.set(true, forKey: key)
    }

    /// 사용자가 이미 리뷰 요청을 했는지 여부
    static var isRequested: Bool {
        UserDefaults.standard.bool(forKey: key)
    }
}
