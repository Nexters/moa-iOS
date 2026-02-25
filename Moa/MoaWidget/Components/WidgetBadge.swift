//
//  WidgetBadge.swift
//  MoaWidgetExtension
//

import SwiftUI

struct WidgetBadge: View {

    let text: String

    var body: some View {
        Text(text)
            .font(Font(AppTypography.c2_400.font()))
            .frame(height: 15)
            .foregroundColor(Color(uiColor: AppColor.IconAndText.mediumEmphasis))
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Color(uiColor: AppColor.Container.secondary))
            .clipShape(RoundedRectangle(cornerRadius: 4.13))
    }
}
