//
//  NicknameEditViewModel.swift
//  Moa
//
//  Created by mirim on 2/19/26.
//

import Foundation

final class NicknameEditViewModel {
    
    // MARK: - Dependencies
    
    private let usecase: OnboardingUsecase
    
    // MARK: - State
    
    private(set) var nickname: String? // TODO: 현재 닉네임 전달 필요
    
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
        
        // FIXME: api 변경
        _ = try await usecase.updateNickname(to: nickname)
    }
}
