//
//  Weekday+Extensions.swift
//  Moa
//
//  Created by mirim on 2/6/26.
//

import Foundation

extension Weekday {
    var displayName: String {
        switch self {
        case .mon: "월"
        case .tue: "화"
        case .wed: "수"
        case .thu: "목"
        case .fri: "금"
        case .sat: "토"
        case .sun: "일"
        }
    }
}
