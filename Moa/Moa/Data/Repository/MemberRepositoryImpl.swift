//
//  MemberRepositoryImpl.swift
//  Moa
//
//  Created by mirim on 2/21/26.
//

import Foundation

final class MemberRepositoryImpl: MemberRepository {
    private let apiClient: APIClient
    
    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    
    func getMember() async throws -> MemberEntity {
        let response: MemberResponse = try await apiClient.request(MemberAPI.getMember)
        
        return response.toDomain()
    }
    
    func withdrawal(reason: [String]) async throws {
        let request = WithdrawalRequest(reason: reason)
        
        let _: EmptyContent = try await apiClient.request(MemberAPI.withdrawal(request))
    }
}
