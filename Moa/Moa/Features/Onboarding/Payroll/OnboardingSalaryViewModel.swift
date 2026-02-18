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
    }
    
    func updateAmount(fromTextFieldText text: String?) {
        let digits = (text ?? "").filter(\.isNumber)
        self.amount = Int(digits)
    }

    // MARK: - Formatting
    
    func koreanCurrencyText(for value: Int) -> String {
        if value < 10_000 { return "" }
        let hundredMillions = value / 100_000_000
        let remainderAfterHundredMillions = value % 100_000_000
        let tenThousands = remainderAfterHundredMillions / 10_000
        if hundredMillions == 0 {
            return "\(tenThousands)만원"
        } else {
            if tenThousands == 0 {
                return "\(hundredMillions)억"
            } else {
                return "\(hundredMillions)억 \(tenThousands)만원"
            }
        }
    }
}
