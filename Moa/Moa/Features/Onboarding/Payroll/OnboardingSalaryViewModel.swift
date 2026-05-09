//
//  OnboardingPayrollViewModel.swift
//  Moa
//
//  Created by mirim on 2/3/26.
//

import Foundation

final class OnboardingPayrollViewModel {
    
    // MARK: - Dependencies
    
    private let usecase: OnboardingUsecase
    
    // MARK: - State
    
    private(set) var selectedSalaryType: SalaryType = .annual
    private(set) var amount: Int?

    // MARK: - Init
    
    init(
        usecase: OnboardingUsecase,
        selectedSalaryType: SalaryType = .annual,
        amount: Int? = nil
    ) {
        self.usecase = usecase
        self.selectedSalaryType = selectedSalaryType
        self.amount = amount
    }

    // MARK: - Actions
    
    func selectSalaryType(_ type: SalaryType) {
        selectedSalaryType = type
    }
    
    func updatePayroll() async throws {
        guard let amount, amount != .zero else { throw DomainError.missingRequiredData }
        _ = try await usecase.updatePayroll(type: selectedSalaryType, amount: amount)
        Analytics.track(.salaryNextClicked(isModified: false))
    }
    
    func updateAmount(fromTextFieldText text: String?) {
        let digits = (text ?? "").filter(\.isNumber)
        self.amount = Int(digits)
    }
}
