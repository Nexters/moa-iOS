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
            settingUsecase: container.settingUsecase,
            currentNickname: currentNickname
        )
        let vc = NicknameEditViewController(viewModel: vm)
        nav?.pushViewController(vc, animated: true)
    }
    
    func moveToPayrollWorkPolicyInfo(accountProvider: AccountProvider) {
        let vm = PayrollWorkPolicyInfoViewModel(
            accountProvider: accountProvider,
            settingUsecase: container.settingUsecase
        )
        let vc = PayrollWorkPolicyInfoViewController(
            viewModel: vm,
            coordinator: self
        )
        
        nav?.pushViewController(vc, animated: true)
    }
    
    func moveToPayrollEdit(salaryType: SalaryType, amount: Int?) {
        let vm = PayrollEditViewModel(
            settingUsecase: container.settingUsecase,
            selectedSalaryType: salaryType,
            amount: amount
        )
        
        let vc = PayrollEditViewController(viewModel: vm)
        
        nav?.pushViewController(vc, animated: true)
    }
    
    func moveToPaydayEdit(currentPayday: Int) {
        let vm = PaydayEditViewModel(settingUsecase: container.settingUsecase, currentPayday: currentPayday)
        let vc = PaydayEditViewController(viewModel: vm)
        
        nav?.pushViewController(vc, animated: true)
    }
    
    func moveToWorkplaceEdit(currentWorkplace: String?) {
        let vm = WorkPlaceEditViewModel(
            settingUsecase: container.settingUsecase,
            currentWorkplace: currentWorkplace
        )
        let vc = WorkPlaceEditViewController(viewModel: vm)
        
        nav?.pushViewController(vc, animated: true)
    }
    
    func moveToWorkPolicyEdit(
        selectedWeekdays: Set<Weekday>,
        clockInTime: TimeIndicatorEntity,
        clockOutTime: TimeIndicatorEntity
    ) {
        let vm = WorkPolicyEditViewModel(
            usecase: container.settingUsecase,
            selectedWeekdays: selectedWeekdays,
            clockInTime: clockInTime,
            clockOutTime: clockOutTime
        )
        
        let vc = WorkPolicyEditViewController(viewModel: vm)
        
        nav?.pushViewController(vc, animated: true)
    }
    
    func moveToTermsAndPolicy() {
        let vm = TermsAndPolicyViewModel(settingUsecase: container.settingUsecase)
        let vc = TermsAndPolicyViewController(viewModel: vm)
        
        nav?.pushViewController(vc, animated: true)
    }
    
    func moveToNotificationSetting() {
        let vm = NotificationSettingViewModel(settingUsecase: container.settingUsecase)
        let vc = NotificationSettingViewController(viewModel: vm)
        
        nav?.pushViewController(vc, animated: true)
    }
    
    func moveToWithdrawal() {
        let vm = WithdrawalViewModel(settingUsecase: container.settingUsecase)
        let vc = WithdrawalViewController(viewModel: vm)
        
        nav?.pushViewController(vc, animated: true)
    }
}
