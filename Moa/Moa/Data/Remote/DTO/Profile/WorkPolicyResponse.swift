//
//  WorkPolicyResponse.swift
//  Moa
//
//  Created by mirim on 2/18/26.
//

import Foundation

struct WorkPolicyResponse: Decodable {
    let workdays: [String]?
    let clockInTime: String?
    let clockOutTime: String?
    
    func toDomain() -> WorkPolicyEntity {
        .init(
            workdays: (workdays ?? []).compactMap(Self.mapWeekday),
            clockInTime: TimeIndicatorEntity(from: clockInTime),
            clockOutTime: TimeIndicatorEntity(from: clockOutTime)
        )
    }
    
    nonisolated private static func mapWeekday(_ raw: String) -> Weekday? {
        switch raw.uppercased() {
        case "MON": return .mon
        case "TUE": return .tue
        case "WED": return .wed
        case "THU": return .thu
        case "FRI": return .fri
        case "SAT": return .sat
        case "SUN": return .sun
        default: return nil
        }
    }
}
