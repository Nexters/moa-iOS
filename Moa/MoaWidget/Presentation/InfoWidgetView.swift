//
//  InfoWidgetView.swift
//  MoaWidgetExtension
//

import AppIntents
import WidgetKit
import SwiftUI

struct InfoWidgetView: View {

    let entry: MoaWidgetEntry

    var body: some View {
        VStack(alignment: .center, spacing: 0) {

            Spacer()

            if let message = entry.data.status.infoMessage {
                Text(message)
                    .font(Font(AppTypography.b2_500.font()))
                    .foregroundColor(Color(uiColor: AppColor.IconAndText.mediumEmphasis))
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
            }

            Spacer()

            if let buttonText = entry.data.status.buttonText {
                actionButton(text: buttonText)
                    .padding(.top, 9)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 16)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: AppColor.Container.primary))
    }

    // MARK: - Action Button
    //
    // iOS 17+: AppIntent 버튼 (앱 미실행 상태로 동작)
    // iOS 16:  widgetURL을 통해 앱을 실행하는 링크 버튼
    //          Button(intent:)는 iOS 17+에서만 지원되므로 반드시 분기 필요

    @ViewBuilder
    private func actionButton(text: String) -> some View {
        if #available(iOS 17.0, *) {
            if entry.data.status == .offline {
                Button(intent: RefreshWidgetIntent()) {
                    buttonLabel(text)
                }
                .buttonStyle(.plain)
            } else {
                // .lowPower → 앱 실행
                Button(intent: OpenAppIntent()) {
                    buttonLabel(text)
                }
                .buttonStyle(.plain)
            }
        } else {
            // iOS 16: widgetURL로 앱 딥링크 실행
            // Link는 위젯에서 허용되지 않으므로 widgetURL을 뷰 전체에 걸고
            // 버튼처럼 보이는 레이블만 렌더링
            buttonLabel(text)
        }
    }

    @ViewBuilder
    private func buttonLabel(_ text: String) -> some View {
        Text(text)
            .font(Font(AppTypography.b2_600.font()))
            .foregroundColor(Color(uiColor: AppColor.IconAndText.highEmphasisReverse))
            .frame(maxWidth: .infinity)
            .frame(minHeight: 33)
            .background(
                Capsule()
                    .fill(Color(uiColor: AppColor.IconAndText.green))
            )
    }
}
