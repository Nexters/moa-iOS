//
//  MoaWidgetUpdater.swift
//  Moa
//

import Foundation
import WidgetKit

enum MoaWidgetUpdater {

    // MARK: - 외부 진입점

    @MainActor
    static func sync(status: WorkStatusEntity, entity: HomeEntity) {
        if ProcessInfo.processInfo.isLowPowerModeEnabled {
            MoaWidgetData(status: .lowPower, displayAmount: 0, updatedAt: .now).save()
            WidgetCenter.shared.reloadAllTimelines()
            return
        }

        let widgetData = resolve(status: status, entity: entity)
        widgetData.save()
        WidgetCenter.shared.reloadAllTimelines()
    }

    // MARK: - WorkStatusEntity → MoaWidgetData

    @MainActor
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
