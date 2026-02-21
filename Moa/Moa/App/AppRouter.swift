//
//  AppRouter.swift
//  Moa
//
//  Created by mirim on 1/25/26.
//

import UIKit

protocol AppRouting: AnyObject {
    func start()
    func routeAfterSplash()
    func routeAfterLogin()
    func navigate(to route: AppRoute, animated: Bool)
}

final class AppRouter: AppRouting {
    private let navigationController: UINavigationController
    private let container: AppContainer
    private var onboardingCoordinator: OnboardingCoordinator?
    private var homeCoordinator: HomeCoordinator?
    
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
    
    func routeAfterSplash() {
        routeToAppropriateDestination()
    }

    func routeAfterLogin() {
        routeToAppropriateDestination()
    }
    
    func navigate(to route: AppRoute, animated: Bool = true) {
        switch route {
        case .splash:
            navigationController.setViewControllers([makeSplash()], animated: animated)
            
        case .login:
            navigationController.setViewControllers([makeLogin()], animated: false) // 스플래시 -> 로그인 넘어갈때는 애니메이션 false 처리
            
        case .home:
            startHome(animated: animated)
            
        case .history:
            break
        }
    }
}

// MARK: - Private

private extension AppRouter {

    func routeToAppropriateDestination() {
        Task { @MainActor in
            let token = AuthSessionManager.shared.currentAccessToken()
            guard let token, !token.isEmpty else {
                navigate(to: .login, animated: false)
                return
            }

            do {
                let status = try await container.onboardingUseCase.getOnboardingStatus()

                switch status.nextOnboardingStep {
                case let .step(step):
                    startOnboarding(animated: true, startStep: step, status: status)
                case .completed:
                    navigate(to: .home, animated: true)
                }
            } catch {
                navigate(to: .login, animated: true)
            }
        }
    }

    func makeSplash() -> UIViewController {
        let vm = SplashViewModel()
        return SplashViewController(viewModel: vm, router: self)
    }
    
    func makeLogin() -> UIViewController {
        let vm = LoginViewModel(authUsecase: container.authUseCase)
        return LoginViewController(viewModel: vm, router: self)
    }
    
    func startOnboarding(animated: Bool, startStep: OnboardingStep, status: OnboardingStatusEntity) {
        let coordinator = OnboardingCoordinator(
            usecase: container.onboardingUseCase,
            startStep: startStep,
            status: status,
            finish: { [weak self] in
                self?.onboardingCoordinator = nil
                self?.navigate(to: .home)
            }
        )
        onboardingCoordinator = coordinator
        coordinator.start(from: navigationController, animated: animated)
    }

    func startHome(animated: Bool) {
        let coordinator = HomeCoordinator(
            container: container
        )
        homeCoordinator = coordinator
        coordinator.start(from: navigationController, animated: animated)
    }
}
