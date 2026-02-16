//
//  UIController.swift
//  Moa
//
//  Created by 정도현 on 2/8/26.
//

import UIKit

// MARK: - Presentation Helper
extension UIViewController {
    func presentBottomSheet(
        _ contentViewController: BottomSheetPresentable,
        configuration: BottomSheetConfiguration = .default,
        delegate: BottomSheetViewControllerDelegate? = nil
    ) {
        let bottomSheet = BottomSheetViewController(
            contentViewController: contentViewController,
            configuration: configuration
        )
        bottomSheet.delegate = delegate
        present(bottomSheet, animated: false)
    }
}
