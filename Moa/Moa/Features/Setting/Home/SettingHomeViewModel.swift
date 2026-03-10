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
    case versionFetched
    case logoutSucceed
}

final class SettingHomeViewModel: BaseViewModel<SettingHomeOutput> {
    
    enum VersionStatus {
        case latest         // 최신버전
        case updateRequired // 업데이트 필요
    }
    
    // MARK: - Dependencies
    private let settingUsecase: SettingUsecase
    
    // MARK: - State
    
    private(set) var accountProvider: AccountProvider = .kakao
    private(set) var nickname: String = ""
    private(set) var currentVersion: String = ""
    private(set) var versionStatus: VersionStatus = .latest

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
            async let version: Void = getVersionInfo()
            
            _ = try await (profile, member, version)
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
    
    func getVersionInfo() async throws {
        let versionInfo = try await settingUsecase.getVersionInfo()
        
        let current = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        
        await MainActor.run {
            self.currentVersion = current
            
            if current.compare(versionInfo.minimumVersion, options: .numeric) == .orderedAscending {
                self.versionStatus = .updateRequired
            } else {
                self.versionStatus = .latest
            }
            
            self.send(.versionFetched)
        }
    }
    
    func logout() {
        guard let fcmToken = AuthSessionManager.shared.currentFcmToken() else {
            return
        }
        
        Task {
            do {
                try await settingUsecase.logout(fcmDeviceToken: fcmToken)
                self.send(.logoutSucceed)
            } catch {
                ToastManager.show(message: "로그아웃에 실패했습니다.")
            }
        }
    }
}
