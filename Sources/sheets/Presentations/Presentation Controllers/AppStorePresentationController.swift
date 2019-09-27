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

    private var closeButton = AppStorePresentationController.createButton()
    private var blurView = UIVisualEffectView.createBlurView()

    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        closeButton.addTarget(self, action: #selector(handleCloseButtonTap), for: .touchUpInside)
    }

    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else { return }

        closeButton.alpha = 0
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        presentedViewController.view.addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.rightAnchor.constraint(equalTo: presentedViewController.view.rightAnchor, constant: -20),
            closeButton.topAnchor.constraint(equalTo: presentedViewController.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            closeButton.heightAnchor.constraint(equalToConstant: 30),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
        ])

        blurView.frame = containerView.bounds
        blurView.alpha = 0
        containerView.addSubview(blurView)

        let animations = {
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

    private static func createButton() -> UIButton {
        if #available(iOS 13, *) {
            let button = UIButton(type: .close)
            return button
        } else {
            let button = UIButton()
            button.backgroundColor = .red
            return button
        }
    }

    @objc private func handleCloseButtonTap() {
        presentingViewController.dismiss(animated: true)
    }

}
