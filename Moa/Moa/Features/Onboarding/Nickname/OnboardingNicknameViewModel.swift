//
//  OnboardingNicknameViewModel.swift
//  Moa
//
//  Created by mirim on 1/30/26.
//

import Foundation
import Combine

final class OnboardingNicknameViewModel {
    
    // MARK: - Dependencies
    
    private let repository: OnboardingRepository
    
    // MARK: - State
    
    private(set) var nickname: String?

    // MARK: - Init
    
    init(
        repository: OnboardingRepository,
        nickname: String? = nil
    ) {
        self.repository = repository
        self.nickname = nickname
    }

    // MARK: - Actions
    
    func makeRandomNickname() -> String {
        repository.generateRandomNickname()
    }
}
