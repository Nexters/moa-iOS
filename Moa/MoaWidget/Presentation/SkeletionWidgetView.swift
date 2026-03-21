//
//  SkeletonWidgetView.swift
//  MoaWidgetExtension
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
        // iOS 17+: contentMarginsDisabled() 적용 시 수동 패딩 필요
        // iOS 16:  시스템 마진 자동 적용되므로 추가 패딩 불필요
        .modifier(SkeletonPaddingModifier())
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: AppColor.Container.primary))
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                opacity = 1.0
            }
        }
    }
}

private struct SkeletonPaddingModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content
                .padding(.vertical, 19)
                .padding(.horizontal, 16)
        } else {
            content
        }
    }
}
