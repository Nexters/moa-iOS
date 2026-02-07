//
//  OnboardingSalaryViewModel.swift
//  Moa
//
//  Created by mirim on 2/3/26.
//

import Foundation

final class OnboardingSalaryViewModel {
    
    // MARK: - State
    
    private(set) var selectedSalaryType: SalaryType = .monthly
    
    // MARK: - Actions
    
    func selectSalaryType(_ type: SalaryType) {
        selectedSalaryType = type
    }
}
