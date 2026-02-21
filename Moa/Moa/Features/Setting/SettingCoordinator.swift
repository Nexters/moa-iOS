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
            profileUsecase: container.profileUsecase,
            currentNickname: currentNickname
        )
        let vc = NicknameEditViewController(viewModel: vm)
        nav?.pushViewController(vc, animated: true)
    }
    
    func moveToPayrollWorkPolicyEdit() { // TODO: 현재 정보 전달
        
    }
}
