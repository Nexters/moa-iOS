//
//  FcmRepositoryImpl.swift
//  Moa
//
//  Created by mirim on 2/24/26.
//

import Foundation

final class FcmRepositoryImpl: FcmRepository {
    private let apiClient: APIClient
    
    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    
    func updateFcmToken(to fcmToken: String) async {
        let request = FcmTokenRequest(token: fcmToken)
        let _ = try? await apiClient.request(FcmAPI.updateFcmToken(request)) as EmptyResponse?
    }
    
    func deleteFcmToken(fcmToken: String) async {
        let request = FcmTokenRequest(token: fcmToken)
        let _ = try? await apiClient.request(FcmAPI.updateFcmToken(request)) as EmptyResponse?
    }
}
