//
//  BottomSheetDismissAnimator.swift
//  Moa
//
//  Created by 정도현 on 2/10/26.
//

import UIKit

/// BottomSheet Animation을 Frame 기반으로 제어
final class BottomSheetDismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let configuration: BottomSheetConfiguration
    
    init(configuration: BottomSheetConfiguration) {
        self.configuration = configuration
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from) else {
            transitionContext.completeTransition(false)
            return
        }
        
        let finalFrame = fromVC.view.frame.offsetBy(
            dx: 0,
            dy: fromVC.view.frame.height
        )
        
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0,
            usingSpringWithDamping: configuration.springDamping,
            initialSpringVelocity: configuration.springVelocity,
            options: .curveEaseInOut
        ) {
            fromVC.view.frame = finalFrame
        } completion: { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
