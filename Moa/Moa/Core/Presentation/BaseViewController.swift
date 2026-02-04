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
        navigationController?.setNavigationBarHidden(true, animated: false)
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
}
