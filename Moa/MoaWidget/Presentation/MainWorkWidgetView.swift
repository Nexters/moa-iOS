//
//  MainWorkWidgetView.swift
//  Moa
//
//  Created by 정도현 on 2/25/26.
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
            .padding(16)
        }
    }
}
