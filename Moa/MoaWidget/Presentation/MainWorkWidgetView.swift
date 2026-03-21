//
//  MainWorkWidgetView.swift
//  MoaWidgetExtension
//

import AppIntents
import WidgetKit
import SwiftUI

struct MainWorkWidgetView: View {

    let entry: MoaWidgetEntry

    var body: some View {
        ZStack(alignment: .topLeading) {

            Color(uiColor: AppColor.Container.primary)

            if let backgroundImage = entry.data.status.backgroundImage {
                Image(uiImage: backgroundImage)
                    .resizable()
                    .scaledToFill()
                    .allowsHitTesting(false)
            }

            VStack(alignment: .leading, spacing: 0) {
                WidgetHeaderView(
                    status: entry.data.status,
                    value:  entry.data.displayAmount
                )

                Spacer()

                if entry.data.status == .working || entry.data.status == .vacation {
                    UpdateRow(updatedAt: entry.data.updatedAt)
                }
            }
            // iOS 17+: contentMarginsDisabled() 사용 시 패딩을 직접 지정
            // iOS 16:  시스템 기본 패딩이 적용되므로 패딩 불필요
            // → #available 분기로 iOS별 패딩 처리
            .modifier(WidgetPaddingModifier())
        }
    }
}

// MARK: - Widget Padding Modifier
//
// contentMarginsDisabled()는 iOS 17+에서만 동작.
// iOS 17+에서는 시스템 마진이 제거되므로 수동으로 패딩을 추가.
// iOS 16에서는 시스템이 자동으로 마진을 적용하므로 추가 패딩 불필요.

private struct WidgetPaddingModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content.padding(16)
        } else {
            content
        }
    }
}
