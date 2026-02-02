//
//  SplashViewController.swift
//  Moa
//
//  Created by mirim on 1/21/26.
//

import UIKit
import SnapKit
import Combine

final class SplashViewController: BaseViewController {
    private let viewModel: SplashViewModel
    private weak var router: AppRouting?
    
    private let logoImageView = UIImageView()
    
    init(viewModel: SplashViewModel, router: AppRouting) {
        self.viewModel = viewModel
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupUI() {
        logoImageView.image = UIImage(resource: .Logo.splash)
        logoImageView.contentMode = .scaleAspectFit
        
        view.addSubview(logoImageView)
        
        logoImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.9)
            make.width.lessThanOrEqualToSuperview().multipliedBy(0.5)
        }
    }
    
    override func bind() {
        bindOutput(viewModel.outputs) { [weak router] output in
            switch output {
            case let .loginChecked(isLoggedIn):
                let destination: AppRoute = isLoggedIn ? .home : .login
                router?.navigate(to: destination, animated: false)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.start()
    }
}

