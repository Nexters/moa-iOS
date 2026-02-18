//
//  PayrollResponse.swift
//  Moa
//
//  Created by mirim on 2/18/26.
//

import Foundation

struct PayrollResponse: Decodable {
    let salaryInputType: String?
    let salaryAmount: Int?
    
    func toDomain() -> PayrollEntity {
        .init(
            salaryInputType: Self.mapSalaryType(salaryInputType),
            salaryAmount: salaryAmount
        )
    }
    
    private static func mapSalaryType(_ raw: String?) -> SalaryType {
        switch (raw ?? "").uppercased() {
        case "MONTHLY": return .monthly
        case "ANNUAL":  return .annual
        default: return .annual
        }
    }
}
