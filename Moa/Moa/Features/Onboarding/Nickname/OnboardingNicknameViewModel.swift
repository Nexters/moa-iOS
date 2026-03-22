//
//  OnboardingNicknameViewModel.swift
//  Moa
//
//  Created by mirim on 1/30/26.
//

import Foundation

enum OnboardingNicknameOutput {
    case logoutSucceed
}

final class OnboardingNicknameViewModel: BaseViewModel<OnboardingNicknameOutput> {
    
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
    
    func logout() {
        // FIXME: 로그아웃시 fcmToken 필수값인지 확인 필요
        guard let fcmToken = AuthSessionManager.shared.currentFcmToken() else {
            return
        }
        
        Task {
            do {
                try await usecase.logout(fcmDeviceToken: fcmToken)
                self.send(.logoutSucceed)
            } catch {
                ToastManager.show(message: "로그아웃에 실패했습니다.")
            }
        }
    }
}
