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
    var route: AnyPublisher<AppRoute, Never> { routeSubject.eraseToAnyPublisher() }
    
    init(minDisplayTime: TimeInterval = 1.0) {
        self.minDisplayTime = minDisplayTime
    }
    
    func start() {
        DispatchQueue.main.asyncAfter(deadline: .now() + minDisplayTime) { [weak self] in
            guard let self else { return }
            
            // TODO: 로그인 여부 검증 및 분기 (로그인/홈)
            self.routeSubject.send(.login)
        }
    }
}
