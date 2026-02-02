//
//  SplashViewModel.swift
//  Moa
//
//  Created by mirim on 1/25/26.
//

import Foundation
import Combine

enum SplashOutput {
    case loginChecked(isLoggedIn: Bool)
}

final class SplashViewModel: BaseViewModel<SplashOutput> {
    private let minDisplayTime: TimeInterval
    private var cancellables = Set<AnyCancellable>()
    
    init(minDisplayTime: TimeInterval = 1.0) {
        self.minDisplayTime = minDisplayTime
    }
    
    func start() {
        Just(())
            .delay(for: .seconds(minDisplayTime), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                // TODO: 로그인 여부 검증 및 분기 (로그인/홈)
                self?.send(.loginChecked(isLoggedIn: false))
            }
            .store(in: &cancellables)
    }
}
