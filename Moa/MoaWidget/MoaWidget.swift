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

    // 위젯 갤러리 미리보기 자리표시자
    func placeholder(in context: Context) -> MoaWidgetEntry {
        MoaWidgetEntry(date: .now, data: .skeleton)
    }

    // 위젯 추가 직후 빠른 스냅샷
    func getSnapshot(in context: Context,
                     completion: @escaping (MoaWidgetEntry) -> Void) {
        completion(MoaWidgetEntry(date: .now, data: MoaWidgetData.load()))
    }

    // 타임라인 정책
    // - 근무 중 / 휴가 : 5분마다 금액 자동 갱신 (앱이 백그라운드여도 동작)
    // - 그 외          : 앱에서 reloadAllTimelines() 호출 시 즉시 갱신. 1시간 폴백.
    func getTimeline(in context: Context,
                     completion: @escaping (Timeline<MoaWidgetEntry>) -> Void) {
        let data  = MoaWidgetData.load()
        let entry = MoaWidgetEntry(date: .now, data: data)

        let refreshMinutes: Int
        switch data.status {
        case .working, .vacation: refreshMinutes = 5
        default:                  refreshMinutes = 60
        }

        let nextRefresh = Calendar.current.date(
            byAdding: .minute, value: refreshMinutes, to: .now
        )!
        completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
    }
}


@main
struct MoaWidget: Widget {
    let kind = "MoaWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MoaWidgetProvider()) { entry in
            MoaWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("MOA 위젯")
        .description("오늘 쌓은 월급을 실시간으로 확인해요.")
        .supportedFamilies([.systemSmall])
        .contentMarginsDisabled()
    }
}
