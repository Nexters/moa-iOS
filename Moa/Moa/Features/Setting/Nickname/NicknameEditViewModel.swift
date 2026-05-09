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
    private let settingUsecase: SettingUsecase
    
    // MARK: - State
    
    private(set) var currentNickname: String?
    
    // MARK: - Init
    
    init(
        onboardingUsecase: OnboardingUsecase,
        settingUsecase: SettingUsecase,
        currentNickname: String? = nil
    ) {
        self.onboardingUsecase = onboardingUsecase
        self.settingUsecase = settingUsecase
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
                
                _ = try await settingUsecase.updateNickname(to: nickname)
                Analytics.track(.nicknameNextClicked(isModified: true))
                self.send(.nicknameEdited)
            } catch {
                ToastManager.show(message: "닉네임 수정에 실패했습니다.")
            }
        }
    }
}
