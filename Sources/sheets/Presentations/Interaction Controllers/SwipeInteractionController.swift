//
//  SwipePresentationController.swift
//  
//
//  Created by Artyom Pstygo on 27.09.2019.
//

import UIKit

private enum Constant {
    static let edgePanDraggingThreshold: CGFloat = 100
    static let scrollableDraggingThreshold: CGFloat = 200
}

class SwipeInteractionController: UIPercentDrivenInteractiveTransition, UIGestureRecognizerDelegate, ScrollableDelegate {

    enum InteractionStatus {
        case notInteracting
        case interacting(lastTranslation: CGFloat)
    }

    enum ScrollableState {
        case idle
        case dragging(lastOffset: CGFloat)
    }

    private(set) var interactionStatus: InteractionStatus = .notInteracting
    private var scrollableState: ScrollableState = .idle

    private weak var viewController: UIViewController!
    private var gestureRecognizers = [UIGestureRecognizer]()

    init(viewController: UIViewController) {
        super.init()
        self.viewController = viewController
        prepareGestureRecognizers(in: viewController)
    }

    private func prepareGestureRecognizers(in viewController: UIViewController) {
        let view = viewController.view!

        let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleEdgePan(_:)))
        edgePan.cancelsTouchesInView = false
        edgePan.edges = .left
        edgePan.delegate = self
        view.addGestureRecognizer(edgePan)
        gestureRecognizers.append(edgePan)

        if let scrollableVC = viewController.asScrollable() {
            scrollableVC.delegate = self
        } else if !(view is UIScrollView) {
            let pan = UIPanGestureRecognizer(target: self, action: #selector(handleEdgePan(_:)))
            pan.cancelsTouchesInView = false
            pan.delegate = self
            view.addGestureRecognizer(pan)
            gestureRecognizers.append(pan)
        }
    }

    @objc private func handleEdgePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: gestureRecognizer.view!.superview!)
        var translationConstant: CGFloat
        var threshold: CGFloat
        if (gestureRecognizer is UIScreenEdgePanGestureRecognizer) {
            translationConstant = translation.x
            threshold = Constant.edgePanDraggingThreshold
        } else {
            translationConstant = translation.y
            threshold = Constant.scrollableDraggingThreshold
        }

        switch gestureRecognizer.state {
        case .began:
            interactionStatus = .interacting(lastTranslation: translationConstant)
            viewController.dismiss(animated: true, completion: nil)

        case .changed:
            interactionStatus = .interacting(lastTranslation: translationConstant)
            handleTranslation(translationConstant, threshold: threshold)

        case .cancelled, .ended:
            interactionStatus = .notInteracting
            cancel()

        default:
            break
        }
    }

    private func handleTranslation(_ translationConstant: CGFloat, threshold: CGFloat) {
        let progress = Self.progress(forTranslation: translationConstant, threshold: threshold)
        update(progress)

        if progress >= 0.5 {
            cleanUp()
            finish()
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

    // MARK: - UIGestureRecognizerDelegate

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UIScreenEdgePanGestureRecognizer, otherGestureRecognizer is UIPanGestureRecognizer {
            return true
        }
        return false
    }

    // MARK: - ScrollableDelegate

    private var dismissing = false

    func scrollableWillBeginDragging(_ scrollView: UIScrollView) {
        interactionStatus = .interacting(lastTranslation: 0)
        scrollableState = .dragging(lastOffset: scrollView.contentOffset.y)
    }

    func scrollableDidScroll(_ scrollView: UIScrollView) {
        guard case let .interacting(lastTranslation) = interactionStatus,
              case let .dragging(lastOffset) = scrollableState else { return }

        let topInset = scrollView.contentInset.top + scrollView.safeAreaInsets.top

        let offset = scrollView.contentOffset.y
        let diff = lastOffset - offset

        // diff > 0 means progress RISES
        // diff < 0 means progress FALLS

        if (diff < 0 && percentComplete > 0) || (diff > 0 && offset <= -topInset) {
            if percentComplete == 0, !dismissing {
                viewController.dismiss(animated: true)
                dismissing = true
            }

            scrollView.contentOffset.y = -topInset

            let translation = lastTranslation + diff
            interactionStatus = .interacting(lastTranslation: translation)
            handleTranslation(translation, threshold: Constant.scrollableDraggingThreshold)

            scrollView.showsVerticalScrollIndicator = false
        } else {
            scrollView.showsVerticalScrollIndicator = true
        }

        scrollableState = .dragging(lastOffset: scrollView.contentOffset.y)
    }

    func scrollableWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        interactionStatus = .notInteracting
        scrollableState = .idle
        dismissing = false
        cancel()
    }

}

