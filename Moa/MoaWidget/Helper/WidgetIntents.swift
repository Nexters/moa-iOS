//
//  WidgetIntents.swift
//  Moa
//
//  Created by 정도현 on 2/25/26.
//

import AppIntents
import WidgetKit

// MARK: - 새로고침 Intent
//
// UpdateRow 아이콘 탭 / 오프라인 "새로고침" 버튼에서 사용
// AppGroup UserDefaults에서 현재 저장된 데이터를 기반으로
// 금액을 재계산한 뒤 타임라인을 즉시 reload

struct RefreshWidgetIntent: AppIntent {

    static let title: LocalizedStringResource = "위젯 새로고침"
    static let description = IntentDescription("위젯 금액과 상태를 지금 즉시 갱신합니다.")

    // 위젯 갱신 후 앱을 열지 않음
    static let openAppWhenRun: Bool = false

    @MainActor
    func perform() async throws -> some IntentResult {
        let current = MoaWidgetData.load()

        // skeleton / lowPower는 재계산 불가 → 그대로 유지
        guard current.status == .working || current.status == .vacation else {
            WidgetCenter.shared.reloadAllTimelines()
            return .result()
        }

        // 근무 중 / 휴가: 현재 시각 기준 금액 재계산
        let refreshed = MoaWidgetData(
            status:        current.status,
            displayAmount: recalculateEarned(from: current),
            updatedAt:     .now
        )
        refreshed.save()
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }

    // MARK: - 정확한 금액 재계산
    //
    // MoaWidgetUpdater.sync()가 저장한 clockInMinutes / clockOutMinutes / dailyPay를 사용.
    // WorkingContentView.earnedAmount()와 동일한 공식:
    //   earnedAmount = dailyPay × (경과 초 / 총 근무 초)

    private func recalculateEarned(from data: MoaWidgetData) -> Int {
        guard
            let inMin  = data.clockInMinutes,
            let outMin = data.clockOutMinutes,
            let pay    = data.dailyPay,
            outMin > inMin
        else {
            // 필드가 없으면 저장된 값 그대로 반환
            return data.displayAmount
        }

        let totalSec = (outMin - inMin) * 60
        let cal      = Calendar.current
        let c        = cal.dateComponents([.hour, .minute], from: .now)
        let nowMin   = (c.hour ?? 0) * 60 + (c.minute ?? 0)
        let elapsed  = max(0, (nowMin - inMin) * 60)
        let ratio    = min(Double(elapsed) / Double(totalSec), 1.0)

        return Int(Double(pay) * ratio)
    }
}

// MARK: - 앱 실행 Intent
//
// 절전 모드 "앱 실행" 버튼에서 사용
// openAppWhenRun = true → 탭 시 앱 포그라운드 진입

struct OpenAppIntent: AppIntent {

    static let title: LocalizedStringResource = "앱 실행"
    static let description = IntentDescription("모아 앱을 실행합니다.")
    static let openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        return .result()
    }
}
