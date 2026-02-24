//
//  AuthUseCase.swift
//  Moa
//
//  Created by mirim on 2/11/26.
//

import Foundation

final class AuthUsecase {
    private let authRepository: AuthRepository
    private let fcmRepository: FcmRepository
    
    init(
        authRepository: AuthRepository,
        fcmRepository: FcmRepository
    ) {
        self.authRepository = authRepository
        self.fcmRepository = fcmRepository
    }
    
    func loginWithKakaoTalk(
        idToken: String,
        fcmDeviceToken: String?
    ) async throws -> SocialLoginEntity {
        let entity = try await authRepository.loginWithKakaoTalk(
            idToken: idToken,
            fcmDeviceToken: fcmDeviceToken
        )
        
        AuthSessionManager.shared.updateTokens(access: entity.accessToken)
        
        return entity
    }
    
    func loginWithApple(
        idToken: String,
        fcmDeviceToken: String?
    ) async throws -> SocialLoginEntity {
        let entity = try await authRepository.loginWithApple(
            idToken: idToken,
            fcmDeviceToken: fcmDeviceToken
        )
        
        AuthSessionManager.shared.updateTokens(access: entity.accessToken)
        
        return entity
    }
    
    func logout(fcmDeviceToken: String) async throws {
        try await authRepository.logout(fcmDeviceToken: fcmDeviceToken)
        if let fcmToken = AuthSessionManager.shared.currentFcmToken() {
            await fcmRepository.deleteFcmToken(fcmToken: fcmToken)
        }
        
        AuthSessionManager.shared.clearTokens()
    }
    
    func updateFcmToken(to fcmToken: String) async {
        await fcmRepository.updateFcmToken(to: fcmToken)
    }
    
    func deleteFcmToken(fcmToken: String) async {
        await fcmRepository.deleteFcmToken(fcmToken: fcmToken)
    }
}
