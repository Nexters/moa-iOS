//
//  OnboardingNicknameViewController.swift
//  Moa
//
//  Created by mirim on 1/30/26.
//

import UIKit
import SnapKit

final class OnboardingNicknameViewController: BaseViewController {
    private let viewModel: OnboardingNicknameViewModel
    private let onNext: (() -> Void)
    
    private let nextButton = AppButton()
    
    init(
        viewModel: OnboardingNicknameViewModel,
        onNext: @escaping (() -> Void)
    ) {
        self.viewModel = viewModel
        self.onNext = onNext
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupUI() {
        replaceSystemBackButtonWithAppBackButton()
        nextButton.setTitle("다음", for: .normal)
        nextButton.applyStyle(.primary())
        
        view.addSubview(nextButton)
        
        nextButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(24)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }
    
    override func setupActions() {
        nextButton.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
    }
    
    @objc private func didTapNext() {
        onNext()
    }
}
