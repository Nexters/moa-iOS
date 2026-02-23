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
        try await authRepository.loginWithKakaoTalk(
            idToken: idToken,
            fcmDeviceToken: fcmDeviceToken
        )
    }
    
    func loginWithApple(
        idToken: String,
        fcmDeviceToken: String?
    ) async throws -> SocialLoginEntity {
        try await authRepository.loginWithApple(
            idToken: idToken,
            fcmDeviceToken: fcmDeviceToken
        )
    }
    
    func updateFcmToken(to fcmToken: String) async {
        await fcmRepository.updateFcmToken(to: fcmToken)
    }
    
    func deleteFcmToken(fcmToken: String) async {
        await fcmRepository.deleteFcmToken(fcmToken: fcmToken)
    }
}
