//
//  LoginViewModel.swift
//  Moa
//
//  Created by mirim on 1/28/26.
//

import Foundation
import Combine
import KakaoSDKUser
import KakaoSDKAuth

enum LoginOutput {
    case loginSucceed
}

final class LoginViewModel: BaseViewModel<LoginOutput> {
    func didTapLogin() {
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk { [weak self] oauthToken, error in
                if let error {
                    print("카카오로 로그인 실패: \(error)")
                } else {
                    print("idToken: \(oauthToken?.idToken)")
                    self?.send(.loginSucceed)
                }
            }
        }
    }
}
