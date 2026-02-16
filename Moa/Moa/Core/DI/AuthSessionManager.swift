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
    
    var currentAccessToken: () -> String? {
        { [weak self] in self?.accessToken }
    }
    
    func updateTokens(access: String?) {
        accessToken = access
        if access == nil { clearTokens() }
    }
    
    func clearTokens() {
        accessToken = nil
    }
}
