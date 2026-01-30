//
//  SplashViewModel.swift
//  Moa
//
//  Created by mirim on 1/25/26.
//

import Foundation
import Combine

final class SplashViewModel {
    private let minDisplayTime: TimeInterval
    private let routeSubject = PassthroughSubject<AppRoute, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    var route: AnyPublisher<AppRoute, Never> { routeSubject.eraseToAnyPublisher() }
    
    init(minDisplayTime: TimeInterval = 1.0) {
        self.minDisplayTime = minDisplayTime
    }
    
    func start() {
        Just(())
            .delay(for: .seconds(minDisplayTime), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                // TODO: 로그인 여부 검증 및 분기 (로그인/홈)
                self?.routeSubject.send(.login)
            }
            .store(in: &cancellables)
    }
}
