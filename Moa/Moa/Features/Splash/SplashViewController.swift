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
    
    private let stackView: UIStackView = {
        let v = UIStackView()
        v.axis = .vertical
        v.spacing = 12
        v.alignment = .fill
        v.distribution = .fill
        return v
    }()
    
    private let primaryButton = AppButton()
    private let secondaryButton = AppButton()
    private let tertiaryButton = AppButton()
    
    init(viewModel: SplashViewModel, router: AppRouting) {
        self.viewModel = viewModel
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupUI() {
        view.backgroundColor = AppColor.Background.primary
        view.addSubview(stackView)
        
        stackView.addArrangedSubview(primaryButton)
        stackView.addArrangedSubview(secondaryButton)
        stackView.addArrangedSubview(tertiaryButton)
        
        primaryButton.setTitle("Primary", for: .normal)
        primaryButton.applyStyle(.primary())
        
        secondaryButton.setTitle("Secondary", for: .normal)
        secondaryButton.applyStyle(.secondary())
        
        tertiaryButton.setTitle("Tertiary(Disabled)", for: .normal)
        tertiaryButton.applyStyle(.tertiary())
        tertiaryButton.isEnabled = false
        
        stackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(24)
        }
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

