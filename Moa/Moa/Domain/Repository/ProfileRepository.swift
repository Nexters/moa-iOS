//
//  ProfileRepository.swift
//  Moa
//
//  Created by mirim on 2/19/26.
//

import Foundation

protocol ProfileRepository {
    func getProfile() async throws -> ProfileEntity
    func updateNickname(to nickname: String?) async throws
    func updateWorkplace(to workplace: String) async throws
    func updatePayday(to payday: Int) async throws -> ProfileEntity
}
