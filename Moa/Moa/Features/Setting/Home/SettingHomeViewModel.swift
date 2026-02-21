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
    private let profileUsecase: ProfileUsecase
    private let memberUsecase: MemberUsecase
    
    // MARK: - State
    
    private(set) var accountProvider: AccountProvider = .kakao
    private(set) var nickname: String = ""
    
    
    // MARK: - Init
    
    init(
        profileUsecase: ProfileUsecase,
        memberUsecase: MemberUsecase
    ) {
        self.profileUsecase = profileUsecase
        self.memberUsecase = memberUsecase
    }
    
    // MARK: - Actions
    
    func viewAppeared() {
        Task {
            async let profileTask: Void = getProfile()
            async let memberTask: Void = getMember()
            
            _ = try await (profileTask, memberTask)
        }
    }
    
    func getProfile() async throws {
        let profile = try await profileUsecase.getProfile()
        await MainActor.run {
            self.nickname = profile.nickname ?? ""
            self.send(.profileFetched)
            
        }
    }
    
    func getMember() async throws {
        let member = try await memberUsecase.getMember()
        await MainActor.run {
            self.accountProvider = member.provider
            self.send(.memberFetched)
        }
    }
}
