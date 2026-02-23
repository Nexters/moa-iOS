//
//  NotificationSettingEntity.swift
//  Moa
//
//  Created by mirim on 2/24/26.
//

import Foundation

struct NotificationSettingEntity {
    let type: NotificationSettingType
    let category: String
    let title: String
    let checked: Bool
}

struct NotificationSection {
    let category: String
    let items: [NotificationSettingEntity]
}
