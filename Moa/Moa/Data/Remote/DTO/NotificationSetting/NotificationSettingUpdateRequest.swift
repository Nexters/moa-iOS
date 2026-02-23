//
//  NotificationSettingUpdateRequest.swift
//  Moa
//
//  Created by mirim on 2/24/26.
//

import Foundation

struct NotificationSettingUpdateRequest: Encodable {
    /// enum - "WORK", "PAYDAY", "MARKETING"
    let type: String
    let checked: Bool
}
