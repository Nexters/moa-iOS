//
//  NotificationSettingRepositoryImpl.swift
//  Moa
//
//  Created by mirim on 2/24/26.
//

import Foundation

final class NotificationSettingRepositoryImpl: NotificationSettingRepository {
    private let apiClient: APIClient
    
    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    
    func getNotificationList() async throws -> [NotificationSettingEntity] {
        let response: [NotificationSettingResponse] = try await apiClient.request(NotificationSettingAPI.getNotification)
        
        return response.map { $0.toDomain() }
    }
    
    func updateNotificationSetting(type: String, checked: Bool) async throws -> [NotificationSettingEntity] {
        let request = NotificationSettingUpdateRequest(type: type, checked: checked)
        let response: [NotificationSettingResponse] = try await apiClient.request(NotificationSettingAPI.updateNotification(request))
        
        return response.map { $0.toDomain() }
    }
}
