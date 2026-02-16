//
//  OnboardingNicknameViewModel.swift
//  Moa
//
//  Created by mirim on 1/30/26.
//

import Foundation
import Combine

final class OnboardingNicknameViewModel {
    // MARK: - State
    private(set) var nickname: String?

    // MARK: - Init
    init(nickname: String? = nil) {
        self.nickname = nickname
    }

    // MARK: - Actions
    func makeRandomNickname() {
        // TODO: 닉네임 랜덤 변경 로직
    }
}
