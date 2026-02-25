//
//  MoneyDescriptionView.swift
//  MoaWidgetExtension
//

import SwiftUI

struct MoneyDescriptionView: View {

    let color: UIColor
    let wage:  Int

    // 매 렌더링마다 생성 방지
    private static let formatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle       = .decimal
        f.groupingSeparator = ","
        return f
    }()

    private var formatted: String {
        Self.formatter.string(from: NSNumber(value: wage)) ?? "\(wage)"
    }

    var body: some View {
        HStack(alignment: .lastTextBaseline, spacing: 2) {
            Text(formatted)
                .font(Font(AppTypography.t3_700.font()))
                .foregroundColor(Color(uiColor: color))
                .minimumScaleFactor(0.6)
                .lineLimit(1)

            Text("원")
                .font(Font(AppTypography.b1_500.font()))
                .foregroundColor(Color(uiColor: AppColor.IconAndText.mediumEmphasis))
        }
    }
}
