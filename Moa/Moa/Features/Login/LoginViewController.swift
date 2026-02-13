//
//  LoginViewController.swift
//  Moa
//
//  Created by mirim on 1/28/26.
//

import UIKit
import SnapKit
import AuthenticationServices

final class LoginViewController: BaseViewController {
    
    // MARK: - Constants
    
    private enum Constant {
        static let loginWithKakaoTalk = "카카오로 계속하기"
        static let loginWithApple = "Apple로 계속하기"
    }
    
    // MARK: - Dependencies
    
    private let viewModel: LoginViewModel
    private weak var router: AppRouting?
    
    // MARK: - UI Components
    
    private let logoImageView = UIImageView()
    private let loginButtonStackView: UIStackView = {
        let v = UIStackView()
        v.axis = .vertical
        v.spacing = 12.0
        v.alignment = .fill
        v.distribution = .fill
        return v
    }()
    
    private let kakaoLoginButton = AppButton()
    private let appleLoginButton = AppButton()
    
    // MARK: - Init
    
    init(viewModel: LoginViewModel, router: AppRouting) {
        self.viewModel = viewModel
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    override func setupUI() {
        logoImageView.image = UIImage(resource: .Logo.login)
        logoImageView.contentMode = .scaleAspectFit
        
        view.addSubview(logoImageView)
        view.addSubview(loginButtonStackView)
        
        loginButtonStackView.addArrangedSubview(kakaoLoginButton)
        loginButtonStackView.addArrangedSubview(appleLoginButton)
        
        logoImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(logoImageView.snp.width).multipliedBy(0.8)
            make.bottom.lessThanOrEqualTo(loginButtonStackView.snp.top).offset(-24)
        }
        
        [kakaoLoginButton, appleLoginButton].forEach { $0.snp.makeConstraints { $0.height.equalTo(64) } }
        
        loginButtonStackView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(24)
        }
        
        kakaoLoginButton.setTitle("카카오로 계속하기", for: .normal)
        kakaoLoginButton.applyStyle(.init(
            enabled: .init(
                backgroundColor: .yellow,
                text: .init(font: AppTypography.t3_700.font(), color: AppColor.IconAndText.highEmphasisReverse)),
            pressed: .init(
                backgroundColor: .yellow,
                text: .init(font: AppTypography.t3_700.font(), color: AppColor.IconAndText.highEmphasisReverse)),
            disabled: .init(
                backgroundColor: .yellow,
                text: .init(font: AppTypography.t3_700.font(), color: AppColor.IconAndText.highEmphasisReverse)),
            cornerRadius: 32,
            verticalPadding: 19,
            image: UIImage(resource: .Icon.iconKakaotalk)
        ))
        
        appleLoginButton.setTitle("Apple로 계속하기", for: .normal)
        appleLoginButton.applyStyle(.tertiary(image: UIImage(resource: .Icon.iconApple)))
    }
    
    override func bind() {
        bindOutput(viewModel.outputs) { [weak router] output in
            switch output {
            case .loginSucceed:
                router?.navigate(to: .onboarding, animated: true)
            case .loginFailed:
                break // TODO: 로그인 실패 처리
            }
        }
    }
    
    override func setupActions() {
        kakaoLoginButton.addTarget(self, action: #selector(didTapKakao), for: .touchUpInside)
        appleLoginButton.addTarget(self, action: #selector(didTapApple), for: .touchUpInside)
    }
    
    @objc private func didTapKakao() {
        viewModel.didTapLoginWithKakaoTalk()
    }
    
    @objc private func didTapApple() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
}

// MARK: - SignIn with Apple Delegate

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        self.view.window ?? UIWindow()
    }
}

extension LoginViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        print("애플로 로그인 실패")
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIdCredential as ASAuthorizationAppleIDCredential:
            let idToken = appleIdCredential.identityToken
            
            if let idToken,
               let idTokenString = String(data: idToken, encoding: .utf8) {
                viewModel.didReceiveInfoFromApple(idToken: idTokenString)
            } else {
                print("토큰 변환 실패")
            }
            
        default:
            break
        }
    }
}
