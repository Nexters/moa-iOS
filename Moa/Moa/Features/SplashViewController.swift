//
//  SplashViewController.swift
//  Moa
//
//  Created by mirim on 1/21/26.
//

import UIKit
import SnapKit

class SplashViewController: UIViewController {

    private let titleLabel: UILabel = {
        let v = UILabel()
        v.text = "Splash"
        v.font = .systemFont(ofSize: 24, weight: .bold)
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Splash"
        
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}

