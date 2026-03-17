//
//  MoaWidgetUpdater.swift
//  Moa
//

import Foundation
import WidgetKit
import Network

enum MoaWidgetUpdater {

    // MARK: - 외부 진입점

    /// WorkViewModel.publish() 직후 호출
    static func sync(status: WorkStatusEntity, entity: HomeEntity) {
        // 1순위: 절전 모드
        if ProcessInfo.processInfo.isLowPowerModeEnabled {
            MoaWidgetData(status: .lowPower, displayAmount: 0, updatedAt: .now).save()
            WidgetCenter.shared.reloadAllTimelines()
            return
        }

        // 2순위: 네트워크 (동기 1회 체크)
        let monitor = NWPathMonitor()
        let sem     = DispatchSemaphore(value: 0)
        var isOnline = true

        monitor.pathUpdateHandler = { path in
            isOnline = path.status == .satisfied
            sem.signal()
        }
        monitor.start(queue: DispatchQueue(label: "moa.widget.network"))
        sem.wait()
        monitor.cancel()

        if !isOnline {
            MoaWidgetData(status: .offline, displayAmount: 0, updatedAt: .now).save()
            WidgetCenter.shared.reloadAllTimelines()
            return
        }

        // 정상 상태 저장
        resolve(status: status, entity: entity).save()
        
        WidgetCenter.shared.reloadAllTimelines()
    }

    // MARK: - WorkStatus → MoaWidgetData

    private static func resolve(status: WorkStatusEntity, entity: HomeEntity) -> MoaWidgetData {
        switch status {
        case .working:
            let ws: MoaWidgetStatus = entity.type == .vacation ? .vacation : .working
            return MoaWidgetData(
                status:          ws,
                displayAmount:   earnedNow(entity),
                updatedAt:       .now,
                clockInMinutes:  entity.clockInTime?.totalMinutes,
                clockOutMinutes: entity.clockOutTime?.totalMinutes,
                dailyPay:        entity.dailyPay
            )

        case .workFinished, .finished, .idle:
            return MoaWidgetData(status: .finished, displayAmount: entity.workedEarnings, updatedAt: .now)
        }
    }

    // MARK: - 현재까지 번 금액 (WorkingContentView.earnedAmount와 동일 공식)

    private static func earnedNow(_ entity: HomeEntity) -> Int {
        guard let ci = entity.clockInTime, let co = entity.clockOutTime else { return 0 }
        let totalSec = max(1, (co.totalMinutes - ci.totalMinutes) * 60)
        let c        = Calendar.current.dateComponents([.hour, .minute], from: .now)
        let nowMin   = (c.hour ?? 0) * 60 + (c.minute ?? 0)
        let elapsed  = max(0, (nowMin - ci.totalMinutes) * 60)
        return Int(Double(entity.dailyPay) * min(Double(elapsed) / Double(totalSec), 1.0))
    }
}
