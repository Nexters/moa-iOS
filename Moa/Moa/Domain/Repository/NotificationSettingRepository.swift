//
//  NotificationSettingRepository.swift
//  Moa
//
//  Created by mirim on 2/24/26.
//

import Foundation

protocol NotificationSettingRepository {
    func getNotificationList() async throws -> [NotificationSettingEntity]
    func updateNotificationSetting(type: String, checked: Bool) async throws -> [NotificationSettingEntity]
}
