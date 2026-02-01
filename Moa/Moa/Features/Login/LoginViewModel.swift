//
//  LoginViewModel.swift
//  Moa
//
//  Created by mirim on 1/28/26.
//

import Foundation
import Combine

enum LoginOutput {
    case loginSucceed
}

final class LoginViewModel: BaseViewModel<LoginOutput> {
    func didTapLogin() {
        // TODO: 로그인 로직
        send(.loginSucceed)
    }
}
