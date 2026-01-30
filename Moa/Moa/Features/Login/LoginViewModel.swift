//
//  LoginViewModel.swift
//  Moa
//
//  Created by mirim on 1/28/26.
//

import Foundation
import Combine

final class LoginViewModel {
    private let routeSubject = PassthroughSubject<AppRoute, Never>()
    var route: AnyPublisher<AppRoute, Never> { routeSubject.eraseToAnyPublisher() }
}
