//
//  SwipePresentationController.swift
//  
//
//  Created by Artyom Pstygo on 27.09.2019.
//

import UIKit

class SwipeInteractionController: UIPercentDrivenInteractiveTransition, UIGestureRecognizerDelegate {

    private(set) var interactionInProgress = false

    private weak var viewController: UIViewController!

    init(viewController: UIViewController) {
        super.init()
        self.viewController = viewController
        prepareGestureRecognizers(in: viewController.view)
    }

    private func prepareGestureRecognizers(in view: UIView) {
        let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleEdgePan(_:)))
        edgePan.cancelsTouchesInView = false
        edgePan.edges = .left
        edgePan.delegate = self
        view.addGestureRecognizer(edgePan)

        if !(view is UIScrollView) {
            let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
            pan.cancelsTouchesInView = false
            pan.delegate = self
            view.addGestureRecognizer(pan)
        }
    }

    @objc private func handleEdgePan(_ gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            gestureRecognizer.setTranslation(.zero, in: gestureRecognizer.view!.superview!)
            interactionInProgress = true
            viewController.dismiss(animated: true, completion: nil)

        case .changed:
            let translation = gestureRecognizer.translation(in: gestureRecognizer.view!.superview!)
            let progress = Self.progress(forTranslation: translation.x, threshold: 100)

            update(progress)

            if progress >= 0.5 {
                gestureRecognizer.view?.removeGestureRecognizer(gestureRecognizer)
                finish()
            }

        case .cancelled, .ended:
            interactionInProgress = false
            cancel()

        default:
            break
        }
    }

    @objc private func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: gestureRecognizer.view!.superview!)
        let progress = Self.progress(forTranslation: translation.y, threshold: 200)

        switch gestureRecognizer.state {
        case .began:
//            gestureRecognizer.setTranslation(.zero, in: gestureRecognizer.view!.superview!)
            if progress > 0 {
                interactionInProgress = true
                viewController.dismiss(animated: true, completion: nil)
            }

        case .changed:
            update(progress)

            if progress >= 0.5 {
                gestureRecognizer.view?.removeGestureRecognizer(gestureRecognizer)
                finish()
            }

        case .cancelled, .ended:
            interactionInProgress = false
            cancel()

        default:
            break
        }
    }

    private static func progress(forTranslation translation: CGFloat, threshold: CGFloat) -> CGFloat {
        if translation < 0 {
            return 0
        } else if translation < threshold {
            return sin((translation / threshold) * (CGFloat.pi / 2)) / 2
        } else {
            return 0.5
        }
    }

    override var completionCurve: UIView.AnimationCurve {
        get { return .linear }
        set {  }
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UIScreenEdgePanGestureRecognizer, otherGestureRecognizer is UIPanGestureRecognizer {
            return true
        }
        return false
    }

}

