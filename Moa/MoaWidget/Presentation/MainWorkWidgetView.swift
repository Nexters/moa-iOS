//
//  MainWorkWidgetView.swift
//  MoaWidgetExtension
//

import WidgetKit
import SwiftUI

struct MainWorkWidgetView: View {

    let entry: MoaWidgetEntry
    
    var body: some View {
        if #available(iOS 17.0, *) {
            content
                .containerBackground(for: .widget) {
                    backgroundView
                }
        } else {
            ZStack {
                backgroundView
                content
            }
        }
    }

    // MARK: - Content

    private var content: some View {
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
        .padding(16)
    }

    // MARK: - Background

    @ViewBuilder
    private var backgroundView: some View {
        ZStack {
            Color(uiColor: AppColor.Container.primary)

            if let backgroundImage = entry.data.status.backgroundImage {
                Image(uiImage: backgroundImage)
                    .resizable()
                    .scaledToFill()
                    .clipped()
            }
        }
    }
}
