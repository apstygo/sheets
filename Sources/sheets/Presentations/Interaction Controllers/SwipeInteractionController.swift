//
//  SwipePresentationController.swift
//  
//
//  Created by Artyom Pstygo on 27.09.2019.
//

import UIKit

class SwipeInteractionController: UIPercentDrivenInteractiveTransition, UIGestureRecognizerDelegate {

    enum InteractionStatus {
        case notInteracting
        case interacting(lastTranslation: CGFloat)
    }

    private(set) var interactionStatus: InteractionStatus = .notInteracting

    private weak var viewController: UIViewController!
    private var gestureRecognizers = [UIGestureRecognizer]()

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
        gestureRecognizers.append(edgePan)

        if !(view is UIScrollView) {
            let pan = UIPanGestureRecognizer(target: self, action: #selector(handleEdgePan(_:)))
            pan.cancelsTouchesInView = false
            pan.delegate = self
            view.addGestureRecognizer(pan)
            gestureRecognizers.append(pan)
        }
    }

    @objc private func handleEdgePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .changed:
            let translation = gestureRecognizer.translation(in: gestureRecognizer.view!.superview!)

            var translationConstant: CGFloat
            if (gestureRecognizer is UIScreenEdgePanGestureRecognizer) {
                translationConstant = translation.x
            } else {
                translationConstant = translation.y
            }

            let progress = Self.progress(forTranslation: translationConstant, threshold: 100)

            if progress > 0, case .notInteracting = interactionStatus {
                interactionStatus = .interacting(lastTranslation: translationConstant)
                viewController.dismiss(animated: true, completion: nil)
            }

            update(progress)
            interactionStatus = .interacting(lastTranslation: translationConstant)

            if progress >= 0.5 {
                cleanUp()
                finish()
            }

        case .cancelled, .ended:
            interactionStatus = .notInteracting
            cancel()

        default:
            break
        }
    }

    private func cleanUp() {
        gestureRecognizers.forEach { viewController.view.removeGestureRecognizer($0) }
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

