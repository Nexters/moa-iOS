//
//  SettingHomeViewModel.swift
//  Moa
//
//  Created by mirim on 2/19/26.
//

import Foundation

enum SettingHomeOutput {
    case profileFetched
    case memberFetched
}

final class SettingHomeViewModel: BaseViewModel<SettingHomeOutput> {
    
    // MARK: - Dependencies
    private let settingUsecase: SettingUsecase
    
    // MARK: - State
    
    private(set) var accountProvider: AccountProvider = .kakao
    private(set) var nickname: String = ""
    
    
    // MARK: - Init
    
    init(
        settingUsecase: SettingUsecase
    ) {
        self.settingUsecase = settingUsecase
    }
    
    // MARK: - Actions
    
    func viewAppeared() {
        Task {
            async let profile: Void = getProfile()
            async let member: Void = getMember()
            
            _ = try await (profile, member)
        }
    }
    
    func getProfile() async throws {
        let profile = try await settingUsecase.getProfile()
        await MainActor.run {
            self.nickname = profile.nickname ?? ""
            self.send(.profileFetched)
            
        }
    }
    
    func getMember() async throws {
        let member = try await settingUsecase.getMember()
        await MainActor.run {
            self.accountProvider = member.provider
            self.send(.memberFetched)
        }
    }
}
