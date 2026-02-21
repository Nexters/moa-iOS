//
//  NicknameEditViewModel.swift
//  Moa
//
//  Created by mirim on 2/19/26.
//

import Foundation

enum NicknameEditOutput {
    case nicknameEdited
}

final class NicknameEditViewModel: BaseViewModel<NicknameEditOutput> {
    
    // MARK: - Dependencies
    
    private let onboardingUsecase: OnboardingUsecase
    private let profileUsecase: SettingUsecase
    
    // MARK: - State
    
    private(set) var currentNickname: String?
    
    // MARK: - Init
    
    init(
        onboardingUsecase: OnboardingUsecase,
        profileUsecase: SettingUsecase,
        currentNickname: String? = nil
    ) {
        self.onboardingUsecase = onboardingUsecase
        self.profileUsecase = profileUsecase
        self.currentNickname = currentNickname
    }

    // MARK: - Actions
    
    func makeRandomNickname() -> String {
        onboardingUsecase.generateRandomNickname()
    }
    
    func updateNickname(to nickname: String?) {
        Task {
            do {
                guard let nickname, !nickname.isEmpty else { throw DomainError.missingRequiredData }
                
                _ = try await profileUsecase.updateNickname(to: nickname)
                
                self.send(.nicknameEdited)
            } catch {
                // TODO: 에러처리
            }
        }
    }
}
