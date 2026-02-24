//
//  PaydayEditViewModel.swift
//  Moa
//
//  Created by mirim on 2/22/26.
//

import Foundation

final class PaydayEditViewModel {
    
    // MARK: - Dependencies
    
    private let settingUsecase: SettingUsecase
    
    // MARK: - State
    
    private(set) var selectedPayday: Int
    
    // MARK: - Init
    
    init(
        settingUsecase: SettingUsecase,
        currentPayday: Int
    ) {
        self.settingUsecase = settingUsecase
        self.selectedPayday = currentPayday
    }
    
    // MARK: - Actions
    
    func selectedPaydayChanged(to payday: Int) {
        selectedPayday = payday
    }
    
    func updatePayday() async throws {
        do {
            _ = try await settingUsecase.updatePayday(to: selectedPayday)
        } catch {
            ToastManager.show(message: "월급일 수정에 실패했습니다.")
        }
    }
}
