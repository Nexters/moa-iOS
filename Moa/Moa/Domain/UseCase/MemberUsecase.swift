//
//  MemberUsecase.swift
//  Moa
//
//  Created by mirim on 2/21/26.
//

import Foundation

final class MemberUsecase {
    private let repository: MemberRepository
    
    init(repository: MemberRepository) {
        self.repository = repository
    }
    
    func getMember() async throws -> MemberEntity {
        try await repository.getMember()
    }
}
