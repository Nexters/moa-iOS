//
//  WorkPolicyRepositoryImpl.swift
//  Moa
//
//  Created by mirim on 2/21/26.
//

import Foundation

final class WorkPolicyRepositoryImpl: WorkPolicyRepository {
    private let apiClient: APIClient
    
    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    
    func getWorkPolicy() async throws -> WorkPolicyEntity {
        let response: WorkPolicyResponse = try await apiClient.request(WorkPolicyAPI.getWorkPolicy)
        
        return response.toDomain()
    }
    
    func updateWorkPolicy(weekdays: [Weekday], clockInTime: TimeIndicatorEntity, clockOutTime: TimeIndicatorEntity) async throws -> WorkPolicyEntity {
        let mapped = weekdays.map { $0.apiValue }
        
        let request = WorkPolicyUpsertRequest(
            workdays: mapped.isEmpty ? nil : mapped,
            clockInTime: clockInTime.displayString,
            clockOutTime: clockOutTime.displayString
        )
        
        let response: WorkPolicyResponse = try await apiClient.request(WorkPolicyAPI.updateWorkPolicy(request))
        
        return response.toDomain()
    }
    
    func updateWorkplace(to workplace: String) async throws {
        let request = WorkplaceUpdateRequest(workplace: workplace)
        let _: WorkPolicyResponse = try await apiClient.request(ProfileAPI.updateWorkplace(request))
    }
}
