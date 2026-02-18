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

    // MARK: - UseCase
    lazy var authUseCase: AuthUsecase = {
        AuthUsecase(repository: authRepository)
    }()
    lazy var onboardingUseCase: OnboardingUsecase = {
        OnboardingUsecase(repository: onboardingRepository)
    }()
}
