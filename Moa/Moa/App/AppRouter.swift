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
    private var onboardingCoordinator: OnboardingCoordinator?
    
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
    
    func navigate(to route: AppRoute, animated: Bool = true) {
        switch route {
        case .splash:
            navigationController.setViewControllers([makeSplash()], animated: animated)
            
        case .login:
            navigationController.setViewControllers([makeLogin()], animated: false) // 스플래시 -> 로그인 넘어갈때는 애니메이션 false 처리
            
        case .onboarding:
            guard onboardingCoordinator == nil else { return }
            startOnboarding(animated: animated)
            
        case .home:
            navigationController.setViewControllers([makeHome()], animated: animated)
            
        case .settings:
            break
        case .history:
            break
        }
    }
}

private extension AppRouter {
    func makeSplash() -> UIViewController {
        let vm = SplashViewModel()
        return SplashViewController(viewModel: vm, router: self)
    }
    
    func makeLogin() -> UIViewController {
        let vm = LoginViewModel()
        return LoginViewController(viewModel: vm, router: self)
    }
    
    func startOnboarding(animated: Bool) {
        let coordinator = OnboardingCoordinator(
            finish: { [weak self] in
                self?.onboardingCoordinator = nil
                self?.navigate(to: .home)
            }
        )
        
        onboardingCoordinator = coordinator
        coordinator.start(from: navigationController, animated: animated)
    }
    
    func makeHome() -> UIViewController {
        return HomeViewController()
    }
}
