//
//  ProfileUsecase.swift
//  Moa
//
//  Created by mirim on 2/19/26.
//

import Foundation

final class ProfileUsecase {
    private let repository: ProfileRepository
    
    init(repository: ProfileRepository) {
        self.repository = repository
    }
    
    func getProfile() async throws -> ProfileEntity {
        try await repository.getProfile()
    }
    
    func updateNickname(to nickname: String?) async throws {
        try await repository.updateNickname(to: nickname)
    }
}
