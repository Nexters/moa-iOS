//
//  UIController.swift
//  Moa
//
//  Created by 정도현 on 2/8/26.
//

import UIKit

// MARK: - Presentation Helper
extension UIViewController {
    func presentBottomSheet(_ contentVC: BottomSheetPresentable) {
        let bottomSheetVC = BottomSheetViewController(
            contentViewController: contentVC
        )
        present(bottomSheetVC, animated: false)
    }
}
