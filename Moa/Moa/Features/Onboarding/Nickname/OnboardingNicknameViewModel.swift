//
//  OnboardingNicknameViewModel.swift
//  Moa
//
//  Created by mirim on 1/30/26.
//

import Foundation

final class OnboardingNicknameViewModel {
    
    // MARK: - Dependencies
    
    private let usecase: OnboardingUsecase
    
    // MARK: - State
    
    private(set) var nickname: String?

    // MARK: - Init
    
    init(
        usecase: OnboardingUsecase,
        nickname: String? = nil
    ) {
        self.usecase = usecase
        self.nickname = nickname
    }

    // MARK: - Actions
    
    func makeRandomNickname() -> String {
        usecase.generateRandomNickname()
    }
    
    func updateNickname(to nickname: String?) async throws {
        guard let nickname, !nickname.isEmpty else { throw DomainError.missingRequiredData }
        _ = try await usecase.updateNickname(to: nickname)
    }
    
    func clearTokens() {
        AuthSessionManager.shared.clearTokens()
    }
}
