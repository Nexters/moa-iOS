//
//  AuthSessionManager.swift
//  Moa
//
//  Created by mirim on 2/16/26.
//

import Foundation

final class AuthSessionManager {
    static let shared = AuthSessionManager()
    private let queue = DispatchQueue(label: "auth.session.manager.queue", attributes: .concurrent)
    
    private init() {}
    
    private var accessToken: String? {
        get {
            queue.sync {
                UserDefaults.standard.string(forKey: "accessToken")
            }
        }
        set {
            queue.async(flags: .barrier) {
                if let token = newValue {
                    UserDefaults.standard.set(token, forKey: "accessToken")
                } else {
                    UserDefaults.standard.removeObject(forKey: "accessToken")
                }
            }
        }
    }
    
    private var fcmToken: String? {
        get {
            queue.sync {
                UserDefaults.standard.string(forKey: "fcmToken")
            }
        }
        set {
            queue.async(flags: .barrier) {
                if let token = newValue {
                    UserDefaults.standard.set(token, forKey: "fcmToken")
                } else {
                    UserDefaults.standard.removeObject(forKey: "fcmToken")
                }
            }
        }
    }
    
    var currentAccessToken: () -> String? {
        { [weak self] in self?.accessToken }
    }
    
    var currentFcmToken: () -> String? {
        { [weak self] in self?.fcmToken }
    }
    
    func updateTokens(access: String?) {
        accessToken = access
    }
    
    func updateTokens(fcm: String?) {
        fcmToken = fcm
    }
    
    func clearTokens() {
        accessToken = nil
        fcmToken = nil
    }
}
