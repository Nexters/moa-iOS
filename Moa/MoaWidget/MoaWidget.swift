//
//  MoaWidget.swift
//  MoaWidgetExtension
//

import WidgetKit
import SwiftUI

// MARK: - Timeline Entry

struct MoaWidgetEntry: TimelineEntry {
    let date: Date
    let data: MoaWidgetData
}

// MARK: - Timeline Provider

struct MoaWidgetProvider: TimelineProvider {

    func placeholder(in context: Context) -> MoaWidgetEntry {
        MoaWidgetEntry(date: .now, data: .skeleton)
    }

    func getSnapshot(in context: Context,
                     completion: @escaping (MoaWidgetEntry) -> Void) {
        var data = MoaWidgetData.load()
        // 저장된 데이터 없음(앱 미실행) → skeleton 대신 finished로 대체
        if data.status == .skeleton {
            data = MoaWidgetData(status: .finished, displayAmount: 0, updatedAt: .now)
        }
        completion(MoaWidgetEntry(date: .now, data: data))
    }

    func getTimeline(in context: Context,
                     completion: @escaping (Timeline<MoaWidgetEntry>) -> Void) {
        let baseData = MoaWidgetData.load()
        print("[MoaWidget] getTimeline — status: \(baseData.status)")

        switch baseData.status {

        case .working, .vacation:
            var entries: [MoaWidgetEntry] = []
            for index in 0..<12 {
                guard let entryDate = Calendar.current.date(
                    byAdding: .minute, value: index * 5, to: .now
                ) else { continue }

                let amount    = recalculateEarned(from: baseData, at: entryDate)
                let entryData = MoaWidgetData(
                    status:          baseData.status,
                    displayAmount:   amount,
                    updatedAt:       entryDate,
                    clockInMinutes:  baseData.clockInMinutes,
                    clockOutMinutes: baseData.clockOutMinutes,
                    dailyPay:        baseData.dailyPay
                )
                entries.append(MoaWidgetEntry(date: entryDate, data: entryData))
            }
            let reloadDate = Calendar.current.date(byAdding: .hour, value: 1, to: .now)!
            completion(Timeline(entries: entries, policy: .after(reloadDate)))

        case .skeleton:
            // 앱 미실행 상태 → 30분 후 재시도
            let entry      = MoaWidgetEntry(date: .now, data: baseData)
            let reloadDate = Calendar.current.date(byAdding: .minute, value: 30, to: .now)!
            completion(Timeline(entries: [entry], policy: .after(reloadDate)))

        default:
            let entry      = MoaWidgetEntry(date: .now, data: baseData)
            let reloadDate = Calendar.current.date(byAdding: .hour, value: 1, to: .now)!
            completion(Timeline(entries: [entry], policy: .after(reloadDate)))
        }
    }

    private func recalculateEarned(from data: MoaWidgetData, at targetDate: Date) -> Int {
        guard
            let clockInMinutes  = data.clockInMinutes,
            let clockOutMinutes = data.clockOutMinutes,
            let dailyPay        = data.dailyPay,
            clockOutMinutes > clockInMinutes
        else { return data.displayAmount }

        let startOfDay     = Calendar.current.startOfDay(for: targetDate)
        let clockInDate    = Calendar.current.date(byAdding: .minute, value: clockInMinutes,  to: startOfDay)!
        let clockOutDate   = Calendar.current.date(byAdding: .minute, value: clockOutMinutes, to: startOfDay)!
        let totalSeconds   = clockOutDate.timeIntervalSince(clockInDate)
        let elapsedSeconds = max(0, targetDate.timeIntervalSince(clockInDate))
        let ratio          = min(elapsedSeconds / totalSeconds, 1.0)
        return Int(Double(dailyPay) * ratio)
    }
}

// MARK: - Widget

@main
struct MoaWidget: Widget {
    let kind = "MoaWidget"

    var body: some WidgetConfiguration {
        let config = StaticConfiguration(kind: kind, provider: MoaWidgetProvider()) { entry in
            MoaWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("MOA 위젯")
        .description("오늘 쌓은 월급을 실시간으로 확인해요.")
        .supportedFamilies([.systemSmall])

        if #available(iOS 17.0, *) {
            return config.contentMarginsDisabled()
        } else {
            return config
        }
    }
}
