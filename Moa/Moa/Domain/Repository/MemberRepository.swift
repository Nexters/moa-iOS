//
//  MemberRepository.swift
//  Moa
//
//  Created by mirim on 2/21/26.
//

import Foundation

protocol MemberRepository {
    func getMember() async throws -> MemberEntity
    func withdrawal(reason: [String]) async throws
}
