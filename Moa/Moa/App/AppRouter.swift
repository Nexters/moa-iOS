//
//  AppRouter.swift
//  Moa
//
//  Created by mirim on 1/25/26.
//

import UIKit

protocol AppRouting: AnyObject {
    func start()
    func routeAfterLogin()
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
            navigationController.setViewControllers([makeHome()], animated: animated)
            
        case .settings:
            break
        case .history:
            break
        }
    }
}

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

                if status.profile == nil {
                    startOnboarding(animated: true, startStep: .nickname, status: status)
                } else if status.payroll == nil {
                    startOnboarding(animated: true, startStep: .salary, status: status)
                } else if status.workPolicy == nil || status.hasRequiredTermsAgreed == false {
                    startOnboarding(animated: true, startStep: .workPolicy, status: status)
                } else {
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
    
    func makeHome() -> UIViewController {
        return HomeViewController()
    }
}
