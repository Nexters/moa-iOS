//
//  AppReviewManager.swift
//  Moa
//

import UIKit
import StoreKit

// MARK: - AppReviewManager
//
// 인앱 리뷰 다이얼로그 노출 트리거를 관리하는 싱글턴
//
// 트리거 조건 (모두 isRequested == false 일 때만 동작):
//   1. 홈 화면 3회 이상 방문
//   2. 근무완료 '완료' 버튼 탭 직후
//   3. 사용자가 설정한 월급일 당일 (하루 1회)

final class AppReviewManager {

    static let shared = AppReviewManager()
    private init() {}

    // MARK: - Triggers

    /// 트리거 1: 홈 화면 방문 시 호출
    func handleHomeVisit() {
        guard !AppReviewStorage.isRequested else { return }

        AppReviewStorage.incrementHomeVisitCount()

        if AppReviewStorage.homeVisitCount >= 3 {
            requestReview()
        }
    }

    /// 트리거 2: 근무완료 '완료' 버튼 탭 직후 호출
    func handleWorkConfirm() {
        guard !AppReviewStorage.isRequested else { return }
        requestReview()
    }

    /// 트리거 3: 홈 화면 진입 시 월급일 여부 확인 후 호출
    /// - Parameter payday: UserDefaults에 저장된 월급일 (1~31, 0이면 미설정)
    func handlePaydayIfNeeded(payday: Int) {
        guard !AppReviewStorage.isRequested else { return }
        guard payday > 0 else { return }
        guard Date().day == payday else { return }
        guard !AppReviewStorage.hasShownPaydayReviewToday else { return }

        AppReviewStorage.markPaydayReviewShownToday()
        requestReview()
    }

    // MARK: - Private

    private func requestReview() {
        guard let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
        else { return }

        AppReviewStorage.markRequested()
        SKStoreReviewController.requestReview(in: scene)
    }
}
