//
//  MoneyDescriptionView.swift
//  MoaWidgetExtension
//

import SwiftUI

struct MoneyDescriptionView: View {

    let color: Color 
    let wage:  Int

    private static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle       = .decimal
        formatter.groupingSeparator = ","
        return formatter
    }()

    private var formattedWage: String {
        Self.formatter.string(from: NSNumber(value: wage)) ?? "\(wage)"
    }

    var body: some View {
        HStack(alignment: .lastTextBaseline, spacing: 2) {
            Text(formattedWage)
                .font(Font(AppTypography.t3_700.font()))
                .foregroundColor(color)
                .minimumScaleFactor(0.6)
                .lineLimit(1)

            Text("원")
                .font(Font(AppTypography.b1_500.font()))
                .foregroundColor(Color(uiColor: AppColor.IconAndText.mediumEmphasis))
        }
    }
}
