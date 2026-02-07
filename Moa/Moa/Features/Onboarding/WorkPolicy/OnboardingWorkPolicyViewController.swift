//
//  OnboardingWorkPolicyViewController.swift
//  Moa
//
//  Created by mirim on 2/5/26.
//

import UIKit

final class OnboardingWorkPolicyViewController: BaseViewController {
    
    // MARK: - Dependencies
    
    private let viewModel: OnboardingWorkPolicyViewModel
    private let onNext: (() -> Void)
    
    init(
        viewModel: OnboardingWorkPolicyViewModel,
        onNext: @escaping () -> Void
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
    }
}
