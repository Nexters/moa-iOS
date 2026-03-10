//
//  LoginViewModel.swift
//  Moa
//
//  Created by mirim on 1/28/26.
//

import Foundation
import KakaoSDKUser
import KakaoSDKAuth
import FirebaseMessaging

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
            loginWithKakaoTalk()
        } else {
            loginWithKakaoAccount() // 카톡 앱 없을 때 웹 로그인
        }
    }
    
    private func loginWithKakaoTalk() {
        UserApi.shared.loginWithKakaoTalk { [weak self] oauthToken, error in
            self?.handleKakaoLoginResult(oauthToken: oauthToken, error: error)
        }
    }
    
    private func loginWithKakaoAccount() {
        UserApi.shared.loginWithKakaoAccount { [weak self] oauthToken, error in
            self?.handleKakaoLoginResult(oauthToken: oauthToken, error: error)
        }
    }
    
    private func handleKakaoLoginResult(oauthToken: OAuthToken?, error: Error?) {
        if let error {
            print("카카오 로그인 실패: \(error)")
            return
        }
        
        guard
            let idToken = oauthToken?.idToken,
            !idToken.isEmpty
        else {
            print("카카오 idToken 없음")
            return
        }
        
        Task { [weak self] in
            guard let self,
                  let fcmToken = AuthSessionManager.shared.currentFcmToken()
            else { return }
            do {
                _ = try await self.authUsecase.loginWithKakaoTalk(
                    idToken: idToken,
                    fcmDeviceToken: fcmToken
                )
                await sendFcmTokenIfAvailable()
                await MainActor.run { self.send(.loginSucceed) }
            } catch {
                print("로그인 요청 실패: \(error.localizedDescription)")
            }
        }
    }
    
    func didReceiveInfoFromApple(idToken: String) {
        Task { [weak self] in
            guard let self,
                  let fcmToken = AuthSessionManager.shared.currentFcmToken()
            else { return }
            do {
                let _ = try await self.authUsecase.loginWithApple(
                    idToken: idToken,
                    fcmDeviceToken: fcmToken
                )
                
                await sendFcmTokenIfAvailable()
                
                await MainActor.run {
                    self.send(.loginSucceed)
                }
            } catch {
                print("로그인 요청 실패: \(error.localizedDescription)")
            }
        }
    }
    
    private func sendFcmTokenIfAvailable() async {
        guard let fcmToken = await getFcmToken() else { return }
        await authUsecase.updateFcmToken(to: fcmToken)
    }

    private func getFcmToken() async -> String? {
        await withCheckedContinuation { continuation in
            Messaging.messaging().token { token, error in
                if let error {
                    print("FCM 토큰 가져오기 실패: \(error)")
                    continuation.resume(returning: nil)
                    return
                }
                continuation.resume(returning: token)
            }
        }
    }
}
