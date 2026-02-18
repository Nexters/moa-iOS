//
//  PayrollUpsertRequest.swift
//  Moa
//
//  Created by mirim on 2/18/26.
//

import Foundation

struct PayrollUpsertRequest: Encodable {
    let salaryInputType: String
    let salaryAmount: Int
}
