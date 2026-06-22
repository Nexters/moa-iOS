//
//  BaseViewModel.swift
//  Moa
//
//  Created by mirim on 2/1/26.
//

import Combine

class BaseViewModel<Output> {
    private let outputSubject = PassthroughSubject<Output, Never>()
    var outputs: AnyPublisher<Output, Never> { outputSubject.eraseToAnyPublisher() }

    func send(_ output: Output) {
        outputSubject.send(output)
    }

    deinit {}
}
