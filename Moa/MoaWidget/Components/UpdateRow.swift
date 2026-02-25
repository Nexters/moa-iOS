//
//  UpdateRow.swift
//  Moa
//
//  Created by 정도현 on 2/25/26.
//

import SwiftUI
import AppIntents

struct UpdateRow: View {
    let updatedAt: Date

    private static let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "a HH:mm"
        f.locale     = Locale(identifier: "ko_KR")
        return f
    }()

    var body: some View {
        HStack(spacing: 3) {
            if #available(iOS 17.0, *) {
                Button(intent: RefreshWidgetIntent()) {
                    Image(uiImage: UIImage(resource: .Icon.iconRefresh))
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(Color(uiColor: AppColor.IconAndText.highEmphasis))
                }
                .buttonStyle(.plain)
            } else {
                Image(uiImage: UIImage(resource: .Icon.iconRefresh))
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(Color(uiColor: AppColor.IconAndText.highEmphasis))
            }
            Text("\(Self.formatter.string(from: updatedAt)) 기준")
                .font(Font(AppTypography.c2_400.font()))
                .foregroundColor(Color(uiColor: AppColor.IconAndText.highEmphasis))
        }
        .padding(.top, 5)
    }
}
