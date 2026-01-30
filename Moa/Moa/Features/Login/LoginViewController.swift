//
//  LoginViewController.swift
//  Moa
//
//  Created by mirim on 1/28/26.
//

import UIKit
import SnapKit

final class LoginViewController: BaseViewController {
    private let viewModel: LoginViewModel
    private weak var router: AppRouting?
    
    private let logoImageView = UIImageView()
    private let loginButtonStackView: UIStackView = {
        let v = UIStackView()
        v.axis = .vertical
        v.spacing = 12.0
        v.alignment = .fill
        v.distribution = .fill
        return v
    }()
    private let kakaoLoginButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("카카오로 계속하기", for: .normal)
        btn.setTitleColor(AppColor.IconAndText.highEmphasisReverse, for: .normal)
        btn.backgroundColor = .yellow
        btn.layer.cornerRadius = 32
        return btn
    }()
    private let appleLoginButton: UIButton = {
       let btn = UIButton()
        btn.setTitle("Apple로 계속하기", for: .normal)
        btn.setTitleColor(AppColor.IconAndText.highEmphasisReverse, for: .normal)
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 32
        return btn
    }()
    
    init(viewModel: LoginViewModel, router: AppRouting) {
        self.viewModel = viewModel
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupUI() {
        logoImageView.image = UIImage(resource: .Logo.login)
        logoImageView.contentMode = .scaleAspectFit
        
        view.addSubview(logoImageView)
        view.addSubview(loginButtonStackView)
        
        // FIXME: 실제 SDK 로그인 버튼으로 수정
        loginButtonStackView.addArrangedSubview(kakaoLoginButton)
        loginButtonStackView.addArrangedSubview(appleLoginButton)
        
        logoImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(0)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(logoImageView.snp.width).multipliedBy(0.8)
        }
        
        kakaoLoginButton.snp.makeConstraints { $0.height.equalTo(64) }
        appleLoginButton.snp.makeConstraints { $0.height.equalTo(64) }
        
        loginButtonStackView.snp.makeConstraints { make in
            make.left.right.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide).inset(24)
        }
    }
    
//    override func bind() {
//        <#code#>
//    }
}
