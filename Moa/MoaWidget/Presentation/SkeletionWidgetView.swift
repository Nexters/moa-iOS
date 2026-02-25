//
//  SkeletionWidgetView.swift
//  Moa
//
//  Created by 정도현 on 2/25/26.
//

import SwiftUI

struct SkeletonWidgetView: View {
    
    @State private var opacity: Double = 0.5

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Capsule()
                .fill(Color(uiColor: AppColor.Container.secondary))
                .frame(width: 60, height: 16)
            
            Capsule()
                .fill(Color(uiColor: AppColor.Container.secondary))
                .frame(maxWidth: .infinity, maxHeight: 16)
            
            Spacer()
        }
        .background(Color(uiColor: AppColor.Container.primary))
        .padding(.vertical, 19)
        .padding(.horizontal, 16)
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                opacity = 1.0
            }
        }
    }
}
