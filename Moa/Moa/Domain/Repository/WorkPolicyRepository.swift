//
//  WorkPolicyRepository.swift
//  Moa
//
//  Created by mirim on 2/21/26.
//

import Foundation

protocol WorkPolicyRepository {
    func getWorkPolicy() async throws -> WorkPolicyEntity
    func updateWorkPolicy(weekdays: [Weekday], clockInTime: String?, clockOutTime: String?) async throws -> WorkPolicyEntity
    func updateWorkplace(to workplace: String) async throws
}
