//
//  OnboardingWorkplaceViewController.swift
//  Moa
//
//  Created by mirim on 2/1/26.
//

import Foundation

final class OnboardingWorkplaceViewController: BaseViewController {
    private let viewModel: OnboardingWorkplaceViewModel
    private let onNext: (() -> Void)
    
    init(
        viewModel: OnboardingWorkplaceViewModel,
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
