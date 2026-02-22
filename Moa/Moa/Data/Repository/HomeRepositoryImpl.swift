//
//  HomeRepository.swift
//  Moa
//
//  Created by 정도현 on 2/22/26.
//

import Foundation

final class HomeRepositoryImpl: HomeRepository {
    
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    
    func fetchData() async throws -> HomeEntity {
        let response: HomeResponse = try await apiClient.request(
            HomeAPI.getData
        )
        
        return response.toDomain()
    }
}
