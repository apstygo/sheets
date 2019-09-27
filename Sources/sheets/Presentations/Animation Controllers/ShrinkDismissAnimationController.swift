//
//  ShrinkDismissAnimationController.swift
//  
//
//  Created by Artyom Pstygo on 27.09.2019.
//

import UIKit

class ShrinkDismissAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        if let transitionContext = transitionContext, !transitionContext.isInteractive {
            return 0.5
        }
        return 0.7
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from) else { return }

        let containerView = transitionContext.containerView
        let duration = transitionDuration(using: transitionContext)

        let blurView = UIVisualEffectView.createBlurView()
        blurView.frame = containerView.bounds
        containerView.insertSubview(blurView, belowSubview: fromVC.view)

        if transitionContext.isInteractive {

            let firstTransform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            let secondTransform = firstTransform.translatedBy(x: 0, y: fromVC.view.frame.size.height * (4/3))

            let initialMasksToBounds = fromVC.view.layer.masksToBounds
            fromVC.view.layer.masksToBounds = true

            UIView.animateKeyframes(
                withDuration: duration,
                delay: 0,
                options: .calculationModeCubic,
                animations: {

                    UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1/2) {
                        fromVC.view.transform = firstTransform
                        fromVC.view.layer.cornerRadius = 15
                    }

                    UIView.addKeyframe(withRelativeStartTime: 1/2, relativeDuration: 1/2) {
                        fromVC.view.transform = secondTransform
                        blurView.alpha = 0
                    }

            },
                completion: { _ in
                    fromVC.view.transform = CGAffineTransform.identity
                    fromVC.view.layer.cornerRadius = 0
                    fromVC.view.layer.masksToBounds = initialMasksToBounds

                    blurView.removeFromSuperview()

                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })

        } else {

            var finalFrame = fromVC.view.frame
            finalFrame.origin.y += finalFrame.size.height

            UIView.animate(
                withDuration: duration,
                delay: 0,
                usingSpringWithDamping: 0.95,
                initialSpringVelocity: 0,
                options: [],
                animations: {
                    blurView.alpha = 0
                    fromVC.view.frame = finalFrame
            },
                completion: { _ in
                    blurView.removeFromSuperview()
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })

        }
    }

}
