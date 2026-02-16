//
//  LoginViewModel.swift
//  Moa
//
//  Created by mirim on 1/28/26.
//

import Foundation
import KakaoSDKUser
import KakaoSDKAuth

enum LoginOutput {
    case loginSucceed
    case loginFailed
}

final class LoginViewModel: BaseViewModel<LoginOutput> {
    private let authUsecase: AuthUsecase
    
    init(authUsecase: AuthUsecase) {
        self.authUsecase = authUsecase
    }
    
    func didTapLoginWithKakaoTalk() {
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk { [weak self] oauthToken, error in
                if let error {
                    print("카카오로 로그인 실패: \(error)")
                    return
                }
                
                guard let self,
                      let idToken = oauthToken?.idToken,
                      !idToken.isEmpty
                      // TODO: 유저디폴트 추상화
                else {
                    return
                }
                
                Task { [weak self] in
                    guard let self = self else { return }
                    do {
                        let accessToken = try await self.authUsecase.loginWithKakaoTalk(
                            idToken: idToken,
                            fcmDeviceToken: UserDefaults.standard.string(forKey: "apnsDeviceToken")
                        ).accessToken
                        
                        UserDefaults.standard.set(accessToken, forKey: "accessToken")
                        
                        await MainActor.run {
                            self.send(.loginSucceed)
                        }
                    } catch {
                        print("로그인 요청 실패: \(error.localizedDescription)")
                    }
                }
            }
        } else {
            print("카카오톡 로그인 불가 상태")
        }
    }
    
    func didReceiveInfoFromApple(idToken: String) {
        Task { [weak self] in
            guard let self else { return }
            do {
                let accessToken = try await self.authUsecase.loginWithApple(
                    idToken: idToken,
                    fcmDeviceToken: UserDefaults.standard.string(forKey: "apnsDeviceToken")
                ).accessToken
                
                UserDefaults.standard.set(accessToken, forKey: "accessToken")
                
                await MainActor.run {
                    self.send(.loginSucceed)
                }
            } catch {
                print("로그인 요청 실패: \(error.localizedDescription)")
            }
        }
    }
}
