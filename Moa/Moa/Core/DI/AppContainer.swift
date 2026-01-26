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

    // MARK: - Network
    lazy var moyaProvider: MoyaProvider<MultiTarget> = {

        let plugins: [PluginType] = [
            MoyaPlugin(tokenProvider: {
                nil     // TODO: 실제 사용되는 TOKEN 주입 필요
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

    // MARK: - UseCase
}
