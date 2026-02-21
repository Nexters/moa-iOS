//
//  PayrollEditViewModel.swift
//  Moa
//
//  Created by mirim on 2/22/26.
//

import Foundation

final class PayrollEditViewModel {
    
    // MARK: - Dependencies
    
    private let settingUsecase: SettingUsecase
    
    // MARK: - State
    
    private(set) var selectedSalaryType: SalaryType
    private(set) var amount: Int?
    
    init(
        settingUsecase: SettingUsecase,
        selectedSalaryType: SalaryType,
        amount: Int?
    ) {
        self.settingUsecase = settingUsecase
        self.selectedSalaryType = selectedSalaryType
        self.amount = amount
    }
    
    // MARK: - Actions
    
    func selectSalaryType(_ type: SalaryType) {
        selectedSalaryType = type
    }
    
    func updatePayroll() async throws {
        guard let amount, amount != .zero else { throw DomainError.missingRequiredData }
        _ = try await settingUsecase.updatePayroll(salaryType: selectedSalaryType, amount: amount)
    }
    
    func updateAmount(fromTextFieldText text: String?) {
        let digits = (text ?? "").filter(\.isNumber)
        self.amount = Int(digits)
    }
}
