//
//  MoaWidgetUpdater.swift
//  Moa
//

import Foundation
import WidgetKit

// MARK: - MoaWidgetUpdater
//
// 네트워크 체크를 제거한 이유:
// - NWPathMonitor 비동기 콜백은 타이밍에 따라 저장이 완료되기 전에
//   reloadAllTimelines()가 호출될 수 있어 skeleton이 보이는 문제 발생
// - 이 함수가 호출되는 시점(WorkViewModel.publish())에
//   이미 서버 통신이 완료된 상태이므로 네트워크 재확인 불필요

enum MoaWidgetUpdater {

    // MARK: - 외부 진입점

    /// WorkViewModel.publish() 직후 호출
    /// @MainActor 환경에서 안전하게 동기 저장 후 위젯 reload
    static func sync(status: WorkStatusEntity, entity: HomeEntity) {
        // 절전 모드
        if ProcessInfo.processInfo.isLowPowerModeEnabled {
            MoaWidgetData(status: .lowPower, displayAmount: 0, updatedAt: .now).save()
            WidgetCenter.shared.reloadAllTimelines()
            return
        }

        // 동기 저장 완료 후 reload — 저장 전에 reload되는 타이밍 문제 해결
        let widgetData = resolve(status: status, entity: entity)
        widgetData.save()
        WidgetCenter.shared.reloadAllTimelines()
    }

    // MARK: - WorkStatusEntity → MoaWidgetData

    private static func resolve(
        status: WorkStatusEntity,
        entity: HomeEntity
    ) -> MoaWidgetData {
        switch status {

        case .working:
            let widgetStatus: MoaWidgetStatus = entity.type == .vacation ? .vacation : .working
            return MoaWidgetData(
                status:          widgetStatus,
                displayAmount:   earnedNow(entity),
                updatedAt:       .now,
                clockInMinutes:  entity.clockInTime?.totalMinutes,
                clockOutMinutes: entity.clockOutTime?.totalMinutes,
                dailyPay:        entity.dailyPay
            )

        case .workFinished, .finished, .idle:
            return MoaWidgetData(
                status:        .finished,
                displayAmount: entity.workedEarnings,
                updatedAt:     .now
            )
        }
    }

    // MARK: - 현재까지 번 금액

    private static func earnedNow(_ entity: HomeEntity) -> Int {
        guard let clockIn  = entity.clockInTime,
              let clockOut = entity.clockOutTime else { return 0 }
        let totalSeconds   = max(1, (clockOut.totalMinutes - clockIn.totalMinutes) * 60)
        let components     = Calendar.current.dateComponents([.hour, .minute], from: .now)
        let nowMinutes     = (components.hour ?? 0) * 60 + (components.minute ?? 0)
        let elapsedSeconds = max(0, (nowMinutes - clockIn.totalMinutes) * 60)
        return Int(Double(entity.dailyPay) * min(Double(elapsedSeconds) / Double(totalSeconds), 1.0))
    }
}
