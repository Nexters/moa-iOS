//
//  WidgetHeaderView.swift
//  MoaWidgetExtension
//

import SwiftUI

struct WidgetHeaderView: View {

    let status: MoaWidgetStatus
    let value:  Int?

    var body: some View {
        switch status {

        // 근무 중 / 휴가: 뱃지 → 금액
        case .working, .vacation:
            VStack(alignment: .leading, spacing: 6) {
                if let badge = status.badgeTitle {
                    WidgetBadge(text: badge)
                }
                if let v = value, let color = status.moneyColor {
                    MoneyDescriptionView(color: color, wage: v)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

        // 완료: "M월 누적 월급" → 금액
        case .finished:
            VStack(alignment: .leading, spacing: 1) {
                if let subtitle = status.subtitleText {
                    Text(subtitle)
                        .font(Font(AppTypography.c1_500.font()))
                        .foregroundColor(Color(uiColor: AppColor.IconAndText.mediumEmphasis))
                        .padding(.top, 2)
                        .padding(.bottom, 2)
                }
                if let v = value, let color = status.moneyColor {
                    MoneyDescriptionView(color: color, wage: v)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

        // 스켈레톤: pill 플레이스홀더
        case .skeleton:
            VStack(alignment: .leading, spacing: 8) {
                Capsule()
                    .fill(Color(uiColor: AppColor.Container.secondary))
                    .frame(width: 48, height: 16)
                Capsule()
                    .fill(Color(uiColor: AppColor.Container.secondary))
                    .frame(maxWidth: .infinity, maxHeight: 16)
            }

        // offline / lowPower: InfoWidgetView에서 처리하므로 여기선 EmptyView
        case .offline, .lowPower:
            EmptyView()
        }
    }
}
