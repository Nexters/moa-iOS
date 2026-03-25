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
        .modifier(WidgetURLModifier())
    }

    // MARK: - Action Button

    @ViewBuilder
    private func actionButton(text: String) -> some View {
        if #available(iOS 17.0, *) {
            if entry.data.status == .offline {
                Button(intent: RefreshWidgetIntent()) {
                    buttonLabel(text)
                }
                .buttonStyle(.plain)
            } else {
                Button(intent: OpenAppIntent()) {
                    buttonLabel(text)
                }
                .buttonStyle(.plain)
            }
        } else {
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

// MARK: - widgetURL Modifier

private struct WidgetURLModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
    }
}
