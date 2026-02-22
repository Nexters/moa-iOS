//
//  NotificationManager.swift
//  Moa
//
//  Created by 정도현 on 2/23/26.
//

import UserNotifications

final class NotificationManager {
    
    static let shared = NotificationManager()
    
    private init() {}
    
    // MARK: - Permission
    
    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
    }
    
    func checkAuthorizationStatus(
        completion: @escaping (UNAuthorizationStatus) -> Void
    ) {
        UNUserNotificationCenter.current()
            .getNotificationSettings { settings in
                DispatchQueue.main.async {
                    completion(settings.authorizationStatus)
                }
            }
    }
}
