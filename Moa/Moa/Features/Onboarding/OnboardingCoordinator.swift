//
//  OnboardingCoordinator.swift
//  Moa
//
//  Created by mirim on 2/1/26.
//

import UIKit

final class OnboardingCoordinator {
    private let usecase: OnboardingUsecase
    private let startStep: OnboardingStep
    private let status: OnboardingStatusEntity
    private let finish: () -> Void
    private weak var nav: UINavigationController?
    
    init(
        usecase: OnboardingUsecase,
        startStep: OnboardingStep,
        status: OnboardingStatusEntity,
        finish: @escaping () -> Void
    ) {
        self.usecase = usecase
        self.startStep = startStep
        self.status = status
        self.finish = finish
    }
    
    func start(from parentNav: UINavigationController, animated: Bool) {
        self.nav = parentNav
        let stack = buildInitialStack(startingAt: startStep, with: status)
        let currentStack = parentNav.viewControllers

        guard let last = stack.last else { return }
        let preceding = Array(stack.dropLast())
        if !preceding.isEmpty {
            parentNav.setViewControllers(currentStack + preceding, animated: false)
        }
        parentNav.pushViewController(last, animated: animated)
    }
}

private extension OnboardingCoordinator {
    // 초기 네비게이션 스택 구성
    func buildInitialStack(
        startingAt startStep: OnboardingStep,
        with status: OnboardingStatusEntity
    ) -> [UIViewController] {
        var stack: [UIViewController] = []
        
        OnboardingStep.allCases.forEach { step in
            if step.orderIndex <= startStep.orderIndex {
                stack.append(buildViewController(for: step, status: status))
            }
        }

        if stack.isEmpty {
            stack.append(buildViewController(for: .nickname, status: status))
        }

        return stack
    }
    
    // 다음 스텝 계산
    func nextStep(after current: OnboardingStep) -> OnboardingStep? {
        let ordered = OnboardingStep.allCases.sorted { $0.orderIndex < $1.orderIndex }
        guard let idx = ordered.firstIndex(of: current), idx + 1 < ordered.count else { return nil }
        return ordered[idx + 1]
    }
    
    // onNext 공통 생성
    func makeOnNext(for current: OnboardingStep) -> (() -> Void) {
        { [weak self] in
            guard let self else { return }
            if let next = self.nextStep(after: current) {
                self.push(to: next)
            } else {
                self.complete()
            }
        }
    }
    
    func buildViewController(
        for step: OnboardingStep,
        status: OnboardingStatusEntity? = nil
    ) -> UIViewController {
        switch step {
        case .nickname:
            let vm = OnboardingNicknameViewModel(
                usecase: usecase,
                nickname: status?.profile?.nickname
            )
            let vc = OnboardingNicknameViewController(
                viewModel: vm,
                onNext: makeOnNext(for: .nickname)
            )
            return vc

        case .payroll:
            let vm = OnboardingPayrollViewModel(
                usecase: usecase,
                selectedSalaryType: status?.payroll?.salaryInputType ?? .annual,
                amount: status?.payroll?.salaryAmount
            )
            let vc = OnboardingPayrollViewController(
                viewModel: vm,
                onNext: makeOnNext(for: .payroll)
            )
            return vc
            
        case .workPolicy:
            let vm = OnboardingWorkPolicyViewModel(
                usecase: usecase,
                selectedWeekdays: Set(status?.workPolicy?.workdays ?? []),
                shouldPresentTermsSheet: {
                    let hasPolicy = status?.workPolicy != nil
                    let agreed = status?.hasRequiredTermsAgreed ?? false
                    return hasPolicy && !agreed
                }(),
                clockInTime: status?.workPolicy?.clockInTime,
                clockOutTime: status?.workPolicy?.clockOutTime
            )
            let vc = OnboardingWorkPolicyViewController(
                viewModel: vm,
                onNext: makeOnNext(for: .workPolicy)
            )
            return vc
        }
    }
    
    func push(to next: OnboardingStep) {
        nav?.pushViewController(buildViewController(for: next), animated: true)
    }
    
    func complete() {
        finish()
    }
}
