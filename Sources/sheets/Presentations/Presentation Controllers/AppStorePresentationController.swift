//
//  AppStorePresentationController.swift
//  sheets
//
//  Created by Artyom Pstygo on 22.09.2019.
//  Copyright © 2019 Artyom Pstygo. All rights reserved.
//

import Foundation
import UIKit

class AppStorePresentationController: UIPresentationController {

    private var closeButton = CloseButton()
    private var blurView = UIVisualEffectView.createBlurView()

    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        closeButton.addTarget(self, action: #selector(handleCloseButtonTap), for: .touchUpInside)
    }

    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else { return }

        closeButton.alpha = 0
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -20),
            closeButton.topAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.topAnchor, constant: 20),
        ])

        blurView.frame = containerView.bounds
        blurView.alpha = 0
        containerView.addSubview(blurView)

        let animations = {
            containerView.bringSubviewToFront(self.closeButton)
            self.closeButton.alpha = 1
            self.blurView.alpha = 1
        }

        if let transitionCoordinator = presentingViewController.transitionCoordinator {
            transitionCoordinator.animate(alongsideTransition: { _ in
                animations()
            },
            completion: nil)
        } else {
            animations()
        }
    }

    override func presentationTransitionDidEnd(_ completed: Bool) {
        blurView.removeFromSuperview()
        if !completed {
            closeButton.removeFromSuperview()
        }
    }

    override func dismissalTransitionWillBegin() {
        let animations = {
            self.closeButton.alpha = 0
            self.blurView.alpha = 0
        }

        if let transitionCoordinator = presentingViewController.transitionCoordinator {
            transitionCoordinator.animate(alongsideTransition: { _ in
                animations()
            },
            completion: nil)
        } else {
            animations()
        }
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            closeButton.removeFromSuperview()
        }
    }

    @objc private func handleCloseButtonTap() {
        presentingViewController.dismiss(animated: true)
    }

}
