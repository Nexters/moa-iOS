//
//  TermsAndPolicyViewController.swift
//  Moa
//
//  Created by mirim on 2/22/26.
//

import UIKit
import SnapKit
import SafariServices

final class TermsAndPolicyViewController: BaseViewController {
    
    // MARK: - Constants
    
    private enum Constants {
        static let termsAndPolicy = "약관 및 정책"
    }
    
    // MARK: - Dependencies
    
    private let viewModel: TermsAndPolicyViewModel
    
    // MARK: - UI Components
    
    private let termsAndPolicyStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        stack.distribution = .fill
        return stack
    }()
    
    // MARK: - Init
    
    init(viewModel: TermsAndPolicyViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTermsAndPolicyUI()
    }
    
    // MARK: - Actions
    
    override func setupUI() {
        replaceSystemBackButtonWithAppBackButton()
        setupNavigationTitle(as: Constants.termsAndPolicy)
        setupLayout()
    }
    
    private func setupLayout() {
        view.addSubview(termsAndPolicyStackView)
        termsAndPolicyStackView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(AppSpacing.screenHorizontal)
            make.top.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }
    
    private func setTermsAndPolicyUI() {
        viewModel.getTermsAndPolicy()
    }
    
    private func presentWeb(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        let safari = SFSafariViewController(url: url)
        safari.modalPresentationStyle = .fullScreen
        present(safari, animated: true)
    }
    
    @objc private func didTapTermDetail(_ sender: UIButton) {
        guard let code = sender.accessibilityIdentifier else { return }
        let urlString = viewModel.urlString(for: code)
        presentWeb(urlString: urlString)
    }
    
    private func didTapTermDetail(code: String) {
        let urlString = viewModel.urlString(for: code)
        presentWeb(urlString: urlString)
    }
    
    override func bind() {
        self.bindOutput(viewModel.outputs) { output in
            switch output {
            case .termsAndPolicyFetched:
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.termsAndPolicyStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
                    
                    if self.viewModel.terms.isEmpty { return }
                    
                    self.viewModel.terms.forEach { term in
                        let row = SettingItemRowView(title: term.title)
                        row.onTap = { [weak self] in
                            self?.didTapTermDetail(code: term.code ?? "")
                        }
                        self.termsAndPolicyStackView.addArrangedSubview(row)
                    }
                }
            }
        }
    }
}

