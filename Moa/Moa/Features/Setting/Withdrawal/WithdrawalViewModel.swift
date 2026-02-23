//
//  WithdrawalViewModel.swift
//  Moa
//
//  Created by mirim on 2/24/26.
//

import Foundation

final class WithdrawalViewModel {
    
    // MARK: - Dependencies
    
    private let settingUsecase: SettingUsecase
    
    init(settingUsecase: SettingUsecase) {
        self.settingUsecase = settingUsecase
    }
    
    func withdrawalButtonTapped(reason: [String]) async throws {
        try await settingUsecase.withdrawal(reason: reason)
    }
}
