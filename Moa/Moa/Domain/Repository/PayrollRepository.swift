//
//  PayrollRepository.swift
//  Moa
//
//  Created by mirim on 2/21/26.
//

import Foundation

protocol PayrollRepository {
    func getPayroll() async throws -> PayrollEntity
    func updateWorkPolicy(salaryInputType: String, salaryAmount: Int) async throws -> PayrollEntity
}
