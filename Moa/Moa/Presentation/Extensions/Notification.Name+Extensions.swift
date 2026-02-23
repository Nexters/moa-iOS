//
//  Notification.Name+Extensions.swift
//  Moa
//
//  Created by mirim on 2/24/26.
//

import Foundation

extension Notification.Name {
    static let fcmTokenRefreshed = Notification.Name("fcmTokenRefreshed")
    static let didLogoutOrWithdrawal = Notification.Name("didLogoutOrWithdrawal")
}
