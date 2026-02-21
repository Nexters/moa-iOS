//
//  SettingCoordinator.swift
//  Moa
//
//  Created by mirim on 2/19/26.
//

import UIKit

final class SettingCoordinator {
    private let container: AppContainer
    private weak var nav: UINavigationController?
    
    init(
        container: AppContainer,
        nav: UINavigationController?
    ) {
        self.container = container
        self.nav = nav
    }
    
    func moveToNicknameEdit(currentNickname: String) {
        let vm = NicknameEditViewModel(
            onboardingUsecase: container.onboardingUseCase,
            profileUsecase: container.settingUsecase,
            currentNickname: currentNickname
        )
        let vc = NicknameEditViewController(viewModel: vm)
        nav?.pushViewController(vc, animated: true)
    }
    
    func moveToPayrollWorkPolicyEdit(accountProvider: AccountProvider) {
        let vm = PayrollWorkPolicyInfoViewModel(
            accountProvider: accountProvider,
            settingUsecase: container.settingUsecase)
        let vc = PayrollWorkPolicyInfoViewController(viewModel: vm)
        
        nav?.pushViewController(vc, animated: true)
    }
}
