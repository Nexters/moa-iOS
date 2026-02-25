//
//  InfoWidgetView.swift
//  Moa
//
//  Created by 정도현 on 2/25/26.
//

import AppIntents
import WidgetKit
import SwiftUI

struct InfoWidgetView: View {
    
    let entry: MoaWidgetEntry
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            
            Spacer()
            
            if let msg = entry.data.status.infoMessage {
                Text(msg)
                    .font(Font(AppTypography.b2_500.font()))
                    .foregroundColor(Color(uiColor: AppColor.IconAndText.mediumEmphasis))
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
            }
            
            Spacer()
            
            if let buttonText = entry.data.status.buttonText {
                if #available(iOS 17.0, *) {
                    // .offline → RefreshWidgetIntent (앱 미실행, 데이터 재계산)
                    // .lowPower → OpenAppIntent (앱 포그라운드 진입)
                    Group {
                        if entry.data.status == .offline {
                            Button(intent: RefreshWidgetIntent()) {
                                buttonLabel(buttonText)
                            }
                        } else {
                            Button(intent: OpenAppIntent()) {
                                buttonLabel(buttonText)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 9)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 16)
                } else {
                    // iOS 16 이하: widgetURL로 앱 실행만 가능
                    buttonLabel(buttonText)
                        .padding(.top, 9)
                        .padding(.horizontal, 12)
                        .padding(.bottom, 16)
                }
            }
        }
        .background(Color(uiColor: AppColor.Container.primary))
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
