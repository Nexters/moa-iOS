//
//  OnboardingCoordinator.swift
//  Moa
//
//  Created by mirim on 2/1/26.
//

import UIKit

final class OnboardingCoordinator {
    enum Step {
        case nickname
        case workPlace
        case salary
        case workPolicy
    }
    
    private let finish: () -> Void
    private weak var nav: UINavigationController?
    
    init(finish: @escaping () -> Void) {
        self.finish = finish
    }
    
    func start(from parentNav: UINavigationController, animated: Bool) {
        self.nav = parentNav
        parentNav.pushViewController(make(step: .nickname), animated: animated)
    }
    
    private func make(step: Step) -> UIViewController {
        switch step {
        case .nickname:
            let vm = OnboardingNicknameViewModel()
            let vc = OnboardingNicknameViewController(
                viewModel: vm,
                onNext: { [weak self] in
                    self?.go(.workPlace)
                }
            )
            return vc
            
        case .workPlace:
            let vm = OnboardingWorkplaceViewModel()
            let vc = OnboardingWorkplaceViewController(
                viewModel: vm,
                onNext: { [weak self] in
                    self?.go(.salary)
                }
            )
            return vc
            
        case .salary:
            let vm = OnboardingSalaryViewModel()
            let vc = OnboardingSalaryViewController(
                viewModel: vm,
                onNext: { [weak self] in
                    self?.go(.workPolicy)
                }
            )
            return vc
            
        case .workPolicy:
            let vm = OnboardingWorkPolicyViewModel()
            let vc = OnboardingWorkPolicyViewController(
                viewModel: vm,
                onNext: { [weak self] in
                    self?.complete()
                }
            )
            return vc
        }
    }
    
    private func go(_ next: Step) {
        nav?.pushViewController(make(step: next), animated: true)
    }
    
    private func complete() {
        finish()
    }
}
