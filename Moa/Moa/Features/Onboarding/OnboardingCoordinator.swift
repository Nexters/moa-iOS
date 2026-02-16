//
//  OnboardingCoordinator.swift
//  Moa
//
//  Created by mirim on 2/1/26.
//

import UIKit

final class OnboardingCoordinator {
    private let startStep: OnboardingStep
    private let status: OnboardingStatusEntity
    private let finish: () -> Void
    private weak var nav: UINavigationController?
    
    init(
        startStep: OnboardingStep,
        status: OnboardingStatusEntity,
        finish: @escaping () -> Void
    ) {
        self.startStep = startStep
        self.status = status
        self.finish = finish
    }
    
    func start(from parentNav: UINavigationController, animated: Bool) {
        self.nav = parentNav
        if startStep == .completed {
            complete()
            return
        }
        let stack = initialStack(for: startStep, with: status)
        parentNav.setViewControllers(stack, animated: animated)
    }
    
    private func initialStack(for step: OnboardingStep, with status: OnboardingStatusEntity) -> [UIViewController] {
        var stack: [UIViewController] = []

        let nicknameVM = OnboardingNicknameViewModel(
            nickname: status.profile?.nickname
        )
        let nicknameVC = OnboardingNicknameViewController(
            viewModel: nicknameVM,
            onNext: { [weak self] in self?.go(.salary) }
        )
        if step == .nickname || status.profile != nil {
            stack.append(nicknameVC)
        }

        let salaryVM = OnboardingSalaryViewModel(
            selectedSalaryType: status.payroll?.salaryInputType ?? .annual,
            amount: status.payroll?.salaryAmount
        )
        let salaryVC = OnboardingSalaryViewController(
            viewModel: salaryVM,
            onNext: { [weak self] in self?.go(.workPolicy) }
        )
        if step == .salary || status.payroll != nil {
            stack.append(salaryVC)
        }

        if step == .workPolicy {
            let workVM = OnboardingWorkPolicyViewModel(
                selectedWeekdays: Set(status.workPolicy?.workdays ?? []),
                shouldPresentTermsSheet: (status.workPolicy != nil) && !(status.hasRequiredTermsAgreed),
                clockInTime: status.workPolicy?.clockInTime,
                clockOutTime: status.workPolicy?.clockOutTime
            )
            let workVC = OnboardingWorkPolicyViewController(
                viewModel: workVM,
                onNext: { [weak self] in self?.complete() }
            )
            stack.append(workVC)
        }

        if stack.isEmpty {
            stack.append(nicknameVC)
        }
        
        return stack
    }
    
    private func go(_ next: OnboardingStep) {
        nav?.pushViewController(make(step: next), animated: true)
    }
    
    private func make(step: OnboardingStep) -> UIViewController {
        switch step {
        case .nickname:
            let vm = OnboardingNicknameViewModel()
            let vc = OnboardingNicknameViewController(
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
            let vm = OnboardingWorkPolicyViewModel(
                selectedWeekdays: Set(status.workPolicy?.workdays ?? []),
                shouldPresentTermsSheet: !(status.hasRequiredTermsAgreed)
            )
            let vc = OnboardingWorkPolicyViewController(
                viewModel: vm,
                onNext: { [weak self] in
                    self?.complete()
                }
            )
            return vc
            
        case .completed:
            // 여기서는 .completed 처리안하고 router에서 처리함
            return UIViewController()
        }
    }
    
    private func complete() {
        finish()
    }
}
