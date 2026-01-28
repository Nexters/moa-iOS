//
//  AppRouter.swift
//  Moa
//
//  Created by mirim on 1/25/26.
//

import UIKit

protocol AppRouting: AnyObject {
    func start()
    func navigate(to route: AppRoute, animated: Bool)
}

final class AppRouter: AppRouting {
    private let navigationController: UINavigationController
    private let container: AppContainer
    
    init(
        navigationController: UINavigationController,
        container: AppContainer
    ) {
        self.navigationController = navigationController
        self.container = container
    }
    
    func start() {
        navigate(to: .splash, animated: false)
    }
    
    func navigate(to route: AppRoute, animated: Bool) {
        switch route {
        case .splash:
            let vm = SplashViewModel()
            let vc = SplashViewController(viewModel: vm, router: self)
            navigationController.setViewControllers([vc], animated: animated)
        case .login:
            break
        case .home:
            break
        case .settings:
            break
        case .history:
            break
        }
    }
}
