//
//  PayrollRepositoryImpl.swift
//  Moa
//
//  Created by mirim on 2/21/26.
//

import Foundation

final class PayrollRepositoryImpl: PayrollRepository {
    private let apiClient: APIClient
    
    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    
    func getPayroll() async throws -> PayrollEntity {
        let response: PayrollResponse = try await apiClient.request(PayrollAPI.getPayroll)
        
        return response.toDomain()
    }
    
    func updatePayroll(salaryInputType: SalaryType, salaryAmount: Int) async throws -> PayrollEntity {
        let request = PayrollUpsertRequest(
            salaryInputType: salaryInputType.apiValue,
            salaryAmount: salaryAmount
        )
        let response: PayrollResponse = try await apiClient.request(PayrollAPI.updatePayroll(request))
        
        return response.toDomain()
    }
    
    
}
