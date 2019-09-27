//
//  AppStoreTransitioningDelegate.swift
//  sheets
//
//  Created by Artyom Pstygo on 22.09.2019.
//  Copyright © 2019 Artyom Pstygo. All rights reserved.
//

import UIKit

public class AppStoreTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {

    private var interactionController: SwipeInteractionController?

    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ShrinkDismissAnimationController()
    }

    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        interactionController = SwipeInteractionController(viewController: presented)
        return AppStorePresentationController(presentedViewController: presented, presenting: presenting)
    }

    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard animator is ShrinkDismissAnimationController,
              let interactionController = interactionController,
              interactionController.interactionInProgress else { return nil }

        return interactionController
    }

}
