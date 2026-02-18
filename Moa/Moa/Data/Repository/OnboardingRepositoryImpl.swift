//
//  OnboardingRepositoryImpl.swift
//  Moa
//
//  Created by mirim on 2/16/26.
//

import Foundation

final class OnboardingRepositoryImpl: OnboardingRepository {
    private let apiClient: APIClient
    
    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    
    func fetchOnboardingStatus() async throws -> OnboardingStatusEntity {
        let response: OnboardingStatusResponse = try await apiClient.request(
            OnboardingAPI.getOnboardingStatus
        )
        
        return response.toDomain()
    }
    
    func generateRandomNickname() -> String {
        let defaultAdj = "100억부자"
        let defaultNoun = "CEO"
        
        do {
            let adjectives: [String] = try loadWordList(resource: "nickname_adjectives")
            let nouns: [String] = try loadWordList(resource: "nickname_nouns")

            let adj = adjectives.randomElement() ?? defaultAdj
            let noun = nouns.randomElement() ?? defaultNoun
            
            let raw = "\(adj)\(noun)"
            let noSpaces = raw.replacingOccurrences(of: "\\s+", with: "", options: .regularExpression)
            let normalized = noSpaces.replacingOccurrences(of: "[^a-zA-Z가-힣]", with: "", options: .regularExpression)
            return normalized.isEmpty ? defaultAdj + defaultNoun : normalized
        } catch {
            return defaultAdj + defaultNoun
        }
    }
    
    private func loadWordList(resource: String, bundle: Bundle = .main) throws -> [String] {
        guard let url = bundle.url(forResource: resource, withExtension: "json") else {
            throw NSError(domain: "OnboardingRepository", code: 1, userInfo: [NSLocalizedDescriptionKey: "리소스를 찾을 수 없습니다: \(resource).json"]) }
        
        let data = try Data(contentsOf: url)
        
        if let array = try? JSONDecoder().decode([String].self, from: data) {
            return array
        } else {
            throw NSError(domain: "OnboardingRepository", code: 2, userInfo: [NSLocalizedDescriptionKey: "JSON 형식이 올바르지 않습니다: \(resource).json"]) }
    }
    
    func updateNickname(to nickname: String) async throws -> ProfileEntity {
        let request = ProfileUpsertRequest(nickname: nickname)
        let response: ProfileResponse = try await apiClient.request(
            OnboardingAPI.updateOnboardingProfile(request)
        )
        
        return response.toDomain()
    }
    
    func updatePayroll(type: SalaryType, amount: Int) async throws -> PayrollEntity {
        let request = PayrollUpsertRequest(salaryInputType: type.apiValue, salaryAmount: amount)
        let response: PayrollResponse = try await apiClient.request(
            OnboardingAPI.updateOnboardingPayroll(request)
        )
        
        return response.toDomain()
    }
    
    func updateWorkPolicy(selectedWeekdays: [Weekday], clockInTime: String, clockOutTime: String) async throws -> WorkPolicyEntity {
        let workdays = selectedWeekdays.compactMap { $0.apiValue }
        let request = WorkPolicyUpsertRequest(workdays: workdays, clockInTime: clockInTime, clockOutTime: clockOutTime)
        let response: WorkPolicyResponse = try await apiClient.request(
            OnboardingAPI.updateOnboardingWorkpolicy(request)
        )
        
        return response.toDomain()
    }
}
