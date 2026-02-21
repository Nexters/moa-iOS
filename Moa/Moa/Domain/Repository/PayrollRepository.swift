//
//  PayrollRepository.swift
//  Moa
//
//  Created by mirim on 2/21/26.
//

import Foundation

protocol PayrollRepository {
    func getPayroll() async throws -> PayrollEntity
    func updatePayroll(salaryInputType: SalaryType, salaryAmount: Int) async throws -> PayrollEntity
}
