//
//  SplashViewModel.swift
//  Moa
//
//  Created by mirim on 1/25/26.
//

import Foundation
import Combine

enum SplashOutput {
    case finished
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
                self?.send(.finished)
            }
            .store(in: &cancellables)
    }
}
