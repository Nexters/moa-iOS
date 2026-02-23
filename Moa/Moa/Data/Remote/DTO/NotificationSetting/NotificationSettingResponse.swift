//
//  NotificationSettingResponse.swift
//  Moa
//
//  Created by mirim on 2/24/26.
//

import Foundation

struct NotificationSettingResponse: Decodable {
    let type: String
    let category: String
    let title: String
    let checked: Bool
    
    func toDomain() -> NotificationSettingEntity {
        .init(
            type: NotificationSettingType(rawValue: type) ?? .work,
            category: category,
            title: title,
            checked: checked
        )
    }
}

enum NotificationSettingType: String, Decodable {
    case work = "WORK"
    case payday = "PAYDAY"
    case marketing = "MARKETING"
    
}
