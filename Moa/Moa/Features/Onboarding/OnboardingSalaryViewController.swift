//
//  OnboardingSalaryViewController.swift
//  Moa
//
//  Created by mirim on 2/3/26.
//

import UIKit
import SnapKit

final class OnboardingSalaryViewController: BaseViewController {
    // MARK: - Constants
    
    private enum Constant {
        
    }
    
    // MARK: - Dependencies
    
    private let viewModel: OnboardingSalaryViewModel
    private let onNext: (() -> Void)
    
    // MARK: - Init
    
    init(
        viewModel: OnboardingSalaryViewModel,
        onNext: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.onNext = onNext
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    override func setupUI() {
        replaceSystemBackButtonWithAppBackButton()
    }
}
