//
//  BaseViewController.swift
//  Moa
//
//  Created by mirim on 1/25/26.
//

import UIKit
import Combine

class BaseViewController: UIViewController {
    var cancellables = Set<AnyCancellable>()
    
    // 네비게이션 바 숨김 여부
    var prefersNavigationBarHidden: Bool {
        false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBaseUI()
        setupUI()
        setupActions()
        bind()
    }
    
    private func setupBaseUI() {
        view.backgroundColor = AppColor.Background.primary
    }
    
    func setupUI() {}
    func setupActions() {}
    func bind() {}
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(
            prefersNavigationBarHidden,
            animated: animated
        )
    }
    
    func bindOutput<Output>(
        _ publisher: AnyPublisher<Output, Never>,
        handler: @escaping (Output) -> Void
    ) {
        publisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: handler)
            .store(in: &cancellables)
    }
    
    // BaseViewController
    func configureNavigationBarAppearance(backgroundColor: UIColor) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = backgroundColor
        appearance.shadowColor = .clear

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
}
