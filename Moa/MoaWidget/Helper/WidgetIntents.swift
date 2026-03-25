//
//  WidgetIntents.swift
//  Moa
//

import AppIntents
import WidgetKit

// MARK: - 새로고침 Intent

struct RefreshWidgetIntent: AppIntent {

    static let title: LocalizedStringResource = "위젯 새로고침"
    static let description = IntentDescription("위젯 금액과 상태를 지금 즉시 갱신합니다.")

    static let openAppWhenRun: Bool = false
    
    func perform() async throws -> some IntentResult {
        let currentData = MoaWidgetData.load()

        guard currentData.status == .working || currentData.status == .vacation else {
            WidgetCenter.shared.reloadTimelines(ofKind: "MoaWidget")
            return .result()
        }

        let refreshedData = MoaWidgetData(
            status:          currentData.status,
            displayAmount:   recalculateEarned(from: currentData),
            updatedAt:       .now,
            clockInMinutes:  currentData.clockInMinutes,
            clockOutMinutes: currentData.clockOutMinutes,
            dailyPay:        currentData.dailyPay
        )
        refreshedData.save()
        WidgetCenter.shared.reloadTimelines(ofKind: "MoaWidget")
        return .result()
    }

    private func recalculateEarned(from data: MoaWidgetData) -> Int {
        guard
            let clockInMinutes  = data.clockInMinutes,
            let clockOutMinutes = data.clockOutMinutes,
            let dailyPay        = data.dailyPay,
            clockOutMinutes > clockInMinutes
        else { return data.displayAmount }

        let now            = Date()
        let startOfDay     = Calendar.current.startOfDay(for: now)
        let clockInDate    = Calendar.current.date(byAdding: .minute, value: clockInMinutes,  to: startOfDay)!
        let clockOutDate   = Calendar.current.date(byAdding: .minute, value: clockOutMinutes, to: startOfDay)!
        let totalSeconds   = clockOutDate.timeIntervalSince(clockInDate)
        let elapsedSeconds = max(0, now.timeIntervalSince(clockInDate))
        let ratio          = min(elapsedSeconds / totalSeconds, 1.0)
        return Int(Double(dailyPay) * ratio)
    }
}

// MARK: - 앱 실행 Intent

struct OpenAppIntent: AppIntent {

    static let title: LocalizedStringResource = "앱 실행"
    static let description = IntentDescription("모아 앱을 실행합니다.")
    static let openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        return .result()
    }
}
