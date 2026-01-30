//
//  UIViewController+Navigation.swift
//  Moa
//
//  Created by mirim on 1/30/26.
//

import UIKit

extension UIViewController {
    func replaceSystemBackButtonWithAppBackButton(action: (() -> Void)? = nil) {
        let button = BackButton()
        button.addAction(
            UIAction(
                handler: { [weak self] _ in
                    guard let self else { return }
                    if let action {
                        action()
                    } else {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            ),
            for: .touchUpInside
        )
        
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
    }
}
