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
            UserApi.shared.loginWithKakaoTalk { [weak self] oauthToken, error in
                if let error {
                    print("카카오로 로그인 실패: \(error)")
                    return
                }
                
                guard let self,
                      let idToken = oauthToken?.idToken,
                      !idToken.isEmpty
                else {
                    return
                }
                
                Task { [weak self] in
                    guard let self = self else { return }
                    do {
                        let _ = try await self.authUsecase.loginWithKakaoTalk(
                            idToken: idToken,
                            fcmDeviceToken: UserDefaults.standard.string(forKey: "apnsDeviceToken")
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
        } else {
            print("카카오톡 로그인 불가 상태")
        }
    }
    
    func didReceiveInfoFromApple(idToken: String) {
        Task { [weak self] in
            guard let self else { return }
            do {
                let _ = try await self.authUsecase.loginWithApple(
                    idToken: idToken,
                    fcmDeviceToken: UserDefaults.standard.string(forKey: "apnsDeviceToken")
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
