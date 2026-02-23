//
//  AppContainer.swift
//  Moa
//
//  Created by 정도현 on 1/26/26.
//

import Foundation
import Moya

final class AppContainer {
    
    static let shared = AppContainer()
    
    private init() {}
    
    // MARK: - Network
    lazy var moyaProvider: MoyaProvider<MultiTarget> = {

        let plugins: [PluginType] = [
            MoyaPlugin(tokenProvider: {
                AuthSessionManager.shared.currentAccessToken()
            }),
            TimeoutPlugin(timeout: 10),
            NetworkLoggingPlugin()
        ]

        return MoyaProvider<MultiTarget>(
            plugins: plugins
        )
    }()

    /// APIClient
    lazy var apiClient: APIClient = {
        MoyaAPIClient(provider: moyaProvider)
    }()

    // MARK: - Repository
    private lazy var authRepository: AuthRepository = {
        AuthRepositoryImpl(apiClient: apiClient)
    }()
    private lazy var onboardingRepository: OnboardingRepository = {
        OnboardingRepositoryImpl(apiClient: apiClient)
    }()
    private lazy var profileRepository: ProfileRepository = {
        ProfileRepositoryImpl(apiClient: apiClient)
    }()
    private lazy var memberRepository: MemberRepository = {
        MemberRepositoryImpl(apiClient: apiClient)
    }()
    private lazy var payrollRepository: PayrollRepository = {
        PayrollRepositoryImpl(apiClient: apiClient)
    }()
    private lazy var workPolicyRepository: WorkPolicyRepository = {
        WorkPolicyRepositoryImpl(apiClient: apiClient)
    }()
    private lazy var workdayRepository: WorkdayRepository = {
        WorkdayRepositoryImpl(apiClient: apiClient)
    }()
    private lazy var homeRepository: HomeRepository = {
        HomeRepositoryImpl(apiClient: apiClient)
    }()
    private lazy var notificationSettingRepository: NotificationSettingRepository = {
        NotificationSettingRepositoryImpl(apiClient: apiClient)
    }()
    private lazy var versionRepository: VersionRepository = {
        VersionRepositoryImpl(apiClient: apiClient)
    }()

    // MARK: - UseCase
    lazy var authUseCase: AuthUsecase = {
        AuthUsecase(repository: authRepository)
    }()
    lazy var onboardingUseCase: OnboardingUsecase = {
        OnboardingUsecase(repository: onboardingRepository)
    }()
    lazy var homeUseCase: HomeUsecase = {
        HomeUsecase(homeRepository: homeRepository, workdayRepository: workdayRepository)
    }()
    lazy var historyUseCase: HistoryUseCase = {
        HistoryUseCase(workdayRepository: workdayRepository)
    }()
    lazy var settingUsecase: SettingUsecase = {
        SettingUsecase(
            profileRepository: profileRepository,
            memberRepository: memberRepository,
            payrollRepository: payrollRepository,
            workPolicyRepository: workPolicyRepository,
            onboardingRepository: onboardingRepository,
            notificationSettingRepository: notificationSettingRepository,
            versionRepository: versionRepository
        )
    }()
}
