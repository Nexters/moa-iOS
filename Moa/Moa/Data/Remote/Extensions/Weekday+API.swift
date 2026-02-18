//
//  Weekday+API.swift
//  Moa
//
//  Created by mirim on 2/18/26.
//

import Foundation

extension Weekday {
    var apiValue: String {
        switch self {
        case .mon: "MON"
        case .tue: "TUE"
        case .wed: "WED"
        case .thu: "THU"
        case .fri: "FRI"
        case .sat: "SAT"
        case .sun: "SUN"
        }
    }
}
