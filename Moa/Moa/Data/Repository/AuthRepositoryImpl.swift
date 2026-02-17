//
//  AuthRepositoryImpl.swift
//  Moa
//
//  Created by mirim on 2/11/26.
//

import Foundation

final class AuthRepositoryImpl: AuthRepository {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    
    func loginWithKakaoTalk(
        idToken: String,
        fcmDeviceToken: String?
    ) async throws -> SocialLoginEntity {
        let response: SocialLoginResponse = try await apiClient.request(
            AuthAPI.kakaoAuth(.init(idToken: idToken, fcmDeviceToken: fcmDeviceToken))
        )
        
        return response.toDomain()
    }
    
    func loginWithApple(
        idToken: String,
        fcmDeviceToken: String?
    ) async throws -> SocialLoginEntity {
        let response: SocialLoginResponse = try await apiClient.request(
            AuthAPI.appleAuth(.init(idToken: idToken, fcmDeviceToken: fcmDeviceToken))
        )
        
        return response.toDomain()
    }
}
