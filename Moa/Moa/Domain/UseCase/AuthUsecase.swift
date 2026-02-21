//
//  AuthUseCase.swift
//  Moa
//
//  Created by mirim on 2/11/26.
//

import Foundation

final class AuthUsecase {
    private let repository: AuthRepository
    
    init(repository: AuthRepository) {
        self.repository = repository
    }
    
    func loginWithKakaoTalk(
        idToken: String,
        fcmDeviceToken: String?
    ) async throws -> SocialLoginEntity {
        try await repository.loginWithKakaoTalk(
            idToken: idToken,
            fcmDeviceToken: fcmDeviceToken
        )
    }
    
    func loginWithApple(
        idToken: String,
        fcmDeviceToken: String?
    ) async throws -> SocialLoginEntity {
        try await repository.loginWithApple(
            idToken: idToken,
            fcmDeviceToken: fcmDeviceToken
        )
    }
}
