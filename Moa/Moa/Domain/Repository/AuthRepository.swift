//
//  AuthRepository.swift
//  Moa
//
//  Created by mirim on 2/11/26.
//

import Foundation

protocol AuthRepository {
    func loginWithKakaoTalk(idToken: String, fcmDeviceToken: String?) async throws -> SocialLoginEntity
    func loginWithApple(idToken: String, fcmDeviceToken: String?) async throws -> SocialLoginEntity
    func logout(fcmDeviceToken: String) async throws
}

