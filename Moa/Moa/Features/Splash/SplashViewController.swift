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
    private unowned let router: AppRouting
    
    init(viewModel: SplashViewModel, router: AppRouting) {
        self.viewModel = viewModel
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupUI() {
        view.backgroundColor = AppColor.IconAndText.green
    }
    
    override func bind() {
        viewModel.route
            .receive(on: DispatchQueue.main)
            .sink { [weak self] route in
                guard let self else { return }
                self.router.navigate(to: route, animated: true)
            }
            .store(in: &cancellables)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.start()
    }
}

