//
//  MoaWidgetEntryView.swift
//  MoaWidgetExtension
//

import WidgetKit
import SwiftUI

struct MoaWidgetEntryView: View {
    let entry: MoaWidgetEntry

    var body: some View {
        switch entry.data.status {
        case .skeleton:                      SkeletonWidgetView()
        case .offline, .lowPower:            InfoWidgetView(entry: entry)
        case .working, .vacation, .finished: MainWorkWidgetView(entry: entry)
        }
    }
}

// MARK: - Preview

@available(iOS 17.0)
#Preview("근무 중", as: .systemSmall) { MoaWidget() } timeline: {
    MoaWidgetEntry(date: .now, data: .init(status: .working,   displayAmount: 43_520,    updatedAt: .now))
}
@available(iOS 17.0)
#Preview("휴가", as: .systemSmall) { MoaWidget() } timeline: {
    MoaWidgetEntry(date: .now, data: .init(status: .vacation,  displayAmount: 87_040,    updatedAt: .now))
}
@available(iOS 17.0)
#Preview("근무완료", as: .systemSmall) { MoaWidget() } timeline: {
    MoaWidgetEntry(date: .now, data: .init(status: .finished,  displayAmount: 1_340_000, updatedAt: .now))
}
@available(iOS 17.0)
#Preview("오프라인", as: .systemSmall) { MoaWidget() } timeline: {
    MoaWidgetEntry(date: .now, data: .init(status: .offline,   displayAmount: 0,         updatedAt: .now))
}
@available(iOS 17.0)
#Preview("절전 모드", as: .systemSmall) { MoaWidget() } timeline: {
    MoaWidgetEntry(date: .now, data: .init(status: .lowPower,  displayAmount: 0,         updatedAt: .now))
}
@available(iOS 17.0)
#Preview("스켈레톤", as: .systemSmall) { MoaWidget() } timeline: {
    MoaWidgetEntry(date: .now, data: .skeleton)
}
