//
//  SwipePresentationController.swift
//  
//
//  Created by Artyom Pstygo on 27.09.2019.
//

import UIKit

class SwipeInteractionController: UIPercentDrivenInteractiveTransition {

    private(set) var interactionInProgress = false

    private weak var viewController: UIViewController!

    init(viewController: UIViewController) {
        super.init()
        self.viewController = viewController
        prepareGestureRecognizer(in: viewController.view)
    }

    private func prepareGestureRecognizer(in view: UIView) {
        let gesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        gesture.edges = .left
        view.addGestureRecognizer(gesture)
    }

    @objc func handleGesture(_ gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            gestureRecognizer.setTranslation(.zero, in: gestureRecognizer.view!.superview!)
            interactionInProgress = true
            viewController.dismiss(animated: true, completion: nil)

        case .changed:
            let translation = gestureRecognizer.translation(in: gestureRecognizer.view!.superview!)
            let progress = Self.progress(forTranslation: translation.x)

            update(progress)

            if progress >= 0.5 {
                gestureRecognizer.view?.removeGestureRecognizer(gestureRecognizer)
//                completionSpeed = 1
                finish()
            }

        case .cancelled, .ended:
            interactionInProgress = false
//            completionSpeed = 3
            cancel()

        default:
            break
        }
    }

    private static func progress(forTranslation translation: CGFloat) -> CGFloat {
        let threshold: CGFloat = 100

        if translation < threshold {
            return sin((translation / threshold) * (CGFloat.pi / 2)) / 2
        } else {
            return 0.5
        }
    }

    override var completionCurve: UIView.AnimationCurve {
        get { return .linear }
        set {  }
    }

}

