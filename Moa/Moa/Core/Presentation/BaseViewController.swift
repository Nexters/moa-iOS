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
        setupUI()
        bind()
    }
    
    func setupUI() {}
    func bind() {}
}
