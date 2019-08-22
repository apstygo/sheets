//
//  SheetController.swift
//  sheets
//
//  Created by Artyom Pstygo on 15.08.2019.
//  Copyright © 2019 Artyom Pstygo. All rights reserved.
//

import Foundation
import UIKit

public enum Anchor {
    case ratio(Double)
    case pointsFromTop(CGFloat)
    case pointsFromBottom(CGFloat)
}

private enum Constant {
    static let dimmingEffectViewMaxAlpha: CGFloat = 0.3
    static let primaryMargin: CGFloat = 20
    static let cornerRadius: CGFloat = 10
    static let defaultPointsFromTopOffset: CGFloat = 20

    static let closeButtonSize: CGFloat = 30
    static let closeButtonTopMargin: CGFloat = 7
    static let closeButtonRightMargin: CGFloat = 10

    static let shadowOffset = CGSize(width: 0, height: 16)
    static let shadowRadius: CGFloat = 16
    static let shadowColor = UIColor.black.cgColor
    static let shadowOpacity: Float = 0.5

    static let defaultSpringDamping: CGFloat = 0.8
    static let originAnimationDuration: TimeInterval = 0.5
    static let viewControllerPushAnimationDuration: TimeInterval = 0.5
    static let viewControllerPopAnimationDuration: TimeInterval = 0.3
}

public class SheetController: UIViewController, ScrollableDelegate {

    private enum GestureState {
        case idle
        case dragging(initialOrigin: CGFloat)
    }

    private enum ContentState {
        case idle
        case dragging(lastContentOffset: CGPoint)
    }

    private enum SnappingLocation {
        case `default`
        case top
        case bottom
    }

    private enum TransitionType {
        case push
        case pop
    }

    // MARK: - Options

    public var expandGestureEnabled = true
    public var closeButtonImage: UIImage?

    // MARK: - Private vars

    private var anchorModels: [Anchor]
    private var gestureState: GestureState = .idle
    private var contentState: ContentState = .idle
    private var isExpanded = true
    private weak var currentScrollable: Scrollable?

    private var _mainViewController: UIViewController
    private var _viewControllers: [UIViewController]
    private var _topViewController: UIViewController

    private lazy var panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleHeaderPanRecognizer(_:)))
    private lazy var tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGestureRecognizer(_:)))

    private lazy var contentView: UIView = {
        let content = UIView()
        content.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        content.layer.cornerRadius = Constant.cornerRadius
        content.layer.masksToBounds = true
        if #available(iOS 13, *) {
            content.backgroundColor = .secondarySystemBackground
        } else {
            content.backgroundColor = .white
        }
        return content
    }()

    private lazy var wrapperView: UIView = {
        let wrapper = UIView()
        wrapper.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        wrapper.layer.cornerRadius = Constant.cornerRadius
        wrapper.layer.shadowOffset = Constant.shadowOffset
        wrapper.layer.shadowRadius = Constant.shadowRadius
        wrapper.layer.shadowColor = Constant.shadowColor
        wrapper.layer.shadowOpacity = Constant.shadowOpacity
        return wrapper
    }()

    private lazy var dimmingEffectView: UIView = {
        let dimming = UIView()
        dimming.backgroundColor = .black
        dimming.alpha = Constant.dimmingEffectViewMaxAlpha
        return dimming
    }()

    public init(mainViewController: UIViewController, rootViewController: UIViewController, anchors: [Anchor]? = nil) {
        _mainViewController = mainViewController
        _viewControllers = [rootViewController]
        _topViewController = rootViewController

        let bottomAnchorConstant: CGFloat
        if let navBar = (rootViewController as? UINavigationController)?.navigationBar {
            bottomAnchorConstant = navBar.bounds.height
        } else {
            bottomAnchorConstant = 100
        }
        self.anchorModels = anchors ?? [.pointsFromTop(Constant.defaultPointsFromTopOffset), .pointsFromBottom(bottomAnchorConstant)]

        super.init(nibName: nil, bundle: nil)

        layoutMainController()
        layoutRootController()
    }

    public override func loadView() {
        view = UIView()
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = .white
        }

        view.addSubview(dimmingEffectView)
        dimmingEffectView.fillContainer()

        wrapperView.addSubview(contentView)
        contentView.fillContainer()
        view.addSubview(wrapperView)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        contentView.addGestureRecognizer(panRecognizer)
        tapRecognizer.cancelsTouchesInView = false
        contentView.addGestureRecognizer(tapRecognizer)
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let targetOrigin = anchorPoints.min()!
        origin = targetOrigin
        adjustContainerSize(targetOrigin: targetOrigin)

        adjustMainVCSafeAreaInsets()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Gestures

    @objc private func handleHeaderPanRecognizer(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            gestureState = .dragging(initialOrigin: origin)
        case .changed:
            let translation = sender.translation(in: contentView)
            if case .dragging(let initialOrigin) = gestureState {
                let newOrigin = trimTargetHeaderOrigin(initialOrigin + translation.y)
                origin = newOrigin
            }
        case .ended:
            gestureState = .idle
            let velocity = sender.velocity(in: contentView).y / 1000
            moveOriginToTheNearestAnchor(withVelocity: velocity)
        case .cancelled, .failed:
            gestureState = .idle
        case .possible:
            break
        }
    }

    @objc private func handleTapGestureRecognizer(_ sender: UITapGestureRecognizer) {
        if expandGestureEnabled, !isExpanded, sender.location(in: contentView).y < headerHeight {
            snapToAnchor(atIndex: 0, animated: true)
            isExpanded = true
        }
    }

    // MARK: - Position Adjustment and Animation

    public func snapToAnchor(atIndex index: Int, animated: Bool) {
        assert(index < anchorPoints.count, "Cannot snap to anchor, because index is out of bounds")
        moveOrigin(to: anchorPoints[index], animated: animated)
    }

    private var origin: CGFloat {
        get {
            return wrapperView.frame.origin.y
        }
        set {
            setContainerOrigin(newValue)
            adjustDimmingEffectViewAlpha(targetOrigin: newValue)
        }
    }

    private func setContainerOrigin(_ value: CGFloat) {
        wrapperView.frame.origin = CGPoint(x: 0, y: value)
    }

    private func adjustContainerSize(targetOrigin: CGFloat) {
        wrapperView.frame.size = CGSize(width: view.bounds.width, height: view.bounds.height - targetOrigin)
    }

    private func adjustDimmingEffectViewAlpha(targetOrigin: CGFloat) {
        let topAnchor = anchorPoints[0]
        let nextAnchor = anchorPoints[1]
        let ratio = 1 - (origin - topAnchor) / (nextAnchor - topAnchor)
        dimmingEffectView.alpha = Constant.dimmingEffectViewMaxAlpha * ratio
    }

    private func adjustMainVCSafeAreaInsets() {
        let additionalBottomInset = availableFrame.maxY - anchorPoints.max()!
        _mainViewController.additionalSafeAreaInsets = UIEdgeInsets(top: 0,
                                                                    left: 0,
                                                                    bottom: additionalBottomInset,
                                                                    right: 0)
    }

    private func moveOrigin(to newOriginY: CGFloat,
                            animated: Bool,
                            velocity: CGFloat = 0,
                            completion: ((Bool) -> Void)? = nil) {
        let animations = {
            self.origin = newOriginY
        }

        UIView.animate(withDuration: animated ? Constant.originAnimationDuration : 0,
                       delay: 0,
                       usingSpringWithDamping: Constant.defaultSpringDamping,
                       initialSpringVelocity: velocity,
                       options: [.allowUserInteraction, .beginFromCurrentState, .curveEaseOut],
                       animations: animations,
                       completion: completion)
    }

    private func moveOriginToTheNearestAnchor(withVelocity velocity: CGFloat,
                                              completion: ((Bool) -> Void)? = nil) {
        let decelerationRate = UIScrollView.DecelerationRate.fast.rawValue
        let projection = origin.project(initialVelocity: velocity, decelerationRate: decelerationRate)

        guard let projectionAnchor = anchorPoints.nearestElement(to: projection) else { return }

        let targetAnchor: CGFloat

        if (projectionAnchor - origin) * velocity < 0 { // if velocity is too low to change the current anchor
            // select the next anchor anyway
            targetAnchor = selectNextAnchor(to: projectionAnchor, velocity: velocity)
        } else {
            targetAnchor = projectionAnchor
        }

        isExpanded = targetAnchor == anchorPoints[0]

        moveOrigin(to: targetAnchor, animated: true, velocity: velocity)
    }

    private func trimTargetHeaderOrigin(_ target: CGFloat) -> CGFloat {
        if target < anchorPoints.min()! {
            return anchorPoints.min()! - sqrt(anchorPoints.min()! - target)
        } else if target > anchorPoints.max()! {
            return anchorPoints.max()! + sqrt(target - anchorPoints.max()!)
        }
        return target
    }

    private func selectNextAnchor(to anchor: CGFloat, velocity: CGFloat) -> CGFloat {
        let index = anchorPoints.firstIndex(of: anchor)!
        let velocityIsPositive = velocity >= 0

        switch (velocityIsPositive, index) {
        case (false, 1 ..< anchorPoints.count):
            return anchorPoints[index-1]
        case (true, 0 ..< anchorPoints.count - 1):
            return anchorPoints[index+1]
        default:
            break
        }

        return anchor
    }

    // MARK: - ScrollableDelegate

    public func scrollableWillBeginDragging(_ scrollView: UIScrollView) {
        contentState = .dragging(lastContentOffset: scrollView.contentOffset)
    }

    public func scrollableDidScroll(_ scrollView: UIScrollView) {
        guard case let .dragging(lastContentOffset) = contentState else { return }

        defer {
            contentState = .dragging(lastContentOffset: scrollView.contentOffset)
        }

        let diff = lastContentOffset.y - scrollView.contentOffset.y
        let topInset = scrollView.contentInset.top + scrollView.safeAreaInsets.top

        if (diff < 0 && origin > anchorPoints.min()!)
            || (diff > 0 && scrollView.contentOffset.y < -topInset) {

            if diff > 0 {
                scrollView.contentOffset.y = -topInset
            } else {
                scrollView.contentOffset.y += diff
            }

            origin = trimTargetHeaderOrigin(origin + diff)

            scrollView.showsVerticalScrollIndicator = false

        } else {
            scrollView.showsVerticalScrollIndicator = true
        }
    }

    public func scrollableWillEndDragging(_ scrollView: UIScrollView,
                                          withVelocity velocity: CGPoint,
                                          targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        contentState = .idle

        guard origin > anchorPoints.min()! else { return }

        /// Stop scrolling
        targetContentOffset.pointee = scrollView.contentOffset

        moveOriginToTheNearestAnchor(withVelocity: -velocity.y)
    }

    // MARK: - Layout

    public func setAnchors(_ anchors: [Anchor], animated: Bool, snapTo index: Int = 0) {
        self.anchorModels = anchors
        adjustMainVCSafeAreaInsets()
        snapToAnchor(atIndex: index, animated: animated)
    }

    public var anchors: [Anchor] {
        return anchorModels
    }

    private func layoutMainController() {
        addAsChild(_mainViewController) { mainView in
            mainView.frame = view.bounds
            view.insertSubview(mainView, belowSubview: dimmingEffectView)
        }
    }

    private func layoutRootController() {
        let rootController = _viewControllers[0]
        addAsChild(_viewControllers[0]) { rootView in
            rootView.frame = contentView.bounds
            contentView.addSubview(rootView)
        }
        bindAsScrollable(viewController: rootController)
    }

    private var availableFrame: CGRect {
        let safeAreaInsets = view.safeAreaInsets
        let bounds = view.bounds
        return bounds.inset(by: safeAreaInsets)
    }

    private var anchorPoints: [CGFloat] {
        return anchorModels.map { anchor in
            switch anchor {
            case let .pointsFromBottom(constant):
                return availableFrame.maxY - constant
            case let .pointsFromTop(constant):
                return availableFrame.minY + constant
            case let .ratio(ratio):
                return availableFrame.minY + CGFloat(ratio) * availableFrame.height
            }
        }
        .sorted()
    }

    private var outOfViewFrame: CGRect {
        return CGRect(origin: contentView.bounds.minXmaxY, size: contentView.bounds.size)
    }

    private var headerHeight: CGFloat {
        if let navController = _topViewController as? UINavigationController {
            return navController.navigationBar.bounds.height
        }
        return 0
    }

    // MARK: - Child-parent relationship

    private func addAsChild(_ childController: UIViewController, layoutClosure: (UIView) -> Void) {
        addChild(childController)
        layoutClosure(childController.view)
        childController.didMove(toParent: self)
    }

    private func removeAsChild(_ childController: UIViewController, layoutClosure: (UIView) -> Void) {
        childController.willMove(toParent: nil)
        layoutClosure(childController.view)
        childController.removeFromParent()
    }

    private func bindAsScrollable(viewController: UIViewController) {
        if let currentScrollable = currentScrollable {
            currentScrollable.delegate = nil
        }

        var candidateVC = viewController
        if let navigationController = viewController as? UINavigationController {
            candidateVC = navigationController.viewControllers[0]
        }

        if let scrollable = candidateVC as? Scrollable {
            scrollable.delegate = self
            currentScrollable = scrollable
        }
    }

    private func cycle(fromViewController oldVC: UIViewController,
                       toViewController newVC: UIViewController,
                       transitionType: TransitionType,
                       animated: Bool) {
        oldVC.willMove(toParent: nil)
        addChild(newVC)

        let newVCStartFrame: CGRect
        let newVCEndFrame: CGRect
        let oldVCEndFrame: CGRect
        let duration: TimeInterval
        let options: UIView.AnimationOptions

        switch transitionType {
        case .push:
            newVCStartFrame = outOfViewFrame
            newVCEndFrame = contentView.bounds
            oldVCEndFrame = contentView.bounds

            duration = Constant.viewControllerPushAnimationDuration
            options = .curveEaseOut

        case .pop:
            newVCStartFrame = contentView.bounds
            newVCEndFrame = contentView.bounds
            oldVCEndFrame = outOfViewFrame

            duration = Constant.viewControllerPopAnimationDuration
            options = []
        }

        newVC.view.frame = newVCStartFrame
        switch transitionType {
        case .push:
            contentView.insertSubview(newVC.view, aboveSubview: oldVC.view)
        case .pop:
            contentView.insertSubview(newVC.view, belowSubview: oldVC.view)
        }

        addCloseButton(toViewController: newVC, transitionType: transitionType)

        let animations = {
            newVC.view.frame = newVCEndFrame
            oldVC.view.frame = oldVCEndFrame
        }

        let completion = { (_: Bool) -> Void in
            oldVC.removeFromParent()
            newVC.didMove(toParent: self)
        }

//        UIView.animate(withDuration: animated ? duration : 0,
//                       delay: 0.0,
//                       options: options,
//                       animations: animations,
//                       completion: completion)

        transition(from: oldVC,
                   to: newVC,
                   duration: false ? duration : 0,
                   options: options,
                   animations: animations,
                   completion: completion)

        bindAsScrollable(viewController: newVC)
    }

    public var topViewController: UIViewController {
        return _topViewController
    }

    public func pushViewController(_ viewController: UIViewController, animated: Bool) {
        cycle(fromViewController: _topViewController,
              toViewController: viewController,
              transitionType: .push,
              animated: animated)
        _viewControllers.append(viewController)
        _topViewController = viewController
    }

    @discardableResult
    public func popViewController(animated: Bool) -> UIViewController? {
        guard _viewControllers.count > 1 else { return nil }

        let from = _viewControllers.popLast()!
        let to = _viewControllers.last!
        cycle(fromViewController: from,
              toViewController: to,
              transitionType: .pop,
              animated: animated)

        _topViewController = to
        return from
    }

    private func addCloseButton(toViewController viewController: UIViewController,
                                transitionType: TransitionType) {
        guard transitionType == .push else { return }

        if let navigationController = viewController as? UINavigationController {
            let systemItem: UIBarButtonItem.SystemItem
            if #available(iOS 13, *) {
                systemItem = .close
            } else {
                systemItem = .done
            }

            let barButton = UIBarButtonItem(barButtonSystemItem: systemItem,
                                            target: self,
                                            action: #selector(closeBarButtonTap(_:)))
            navigationController.viewControllers[0].navigationItem.setRightBarButton(barButton, animated: true)

        } else {
            let button = UIButton()
            button.addTarget(self, action: #selector(closeButtonTap(_:)), for: .touchUpInside)

            var image = closeButtonImage
            if #available(iOS 13, *) {
                button.imageView?.tintColor = .systemGray2
                button.imageView?.contentMode = .scaleAspectFit
                let largeConfig = UIImage.SymbolConfiguration(textStyle: .largeTitle)
                image = closeButtonImage ?? UIImage(systemName: "xmark.circle.fill", withConfiguration: largeConfig)
            }
            button.setImage(image, for: .normal)

            let availableSize = viewController.view.bounds.size
            button.frame = CGRect(x: availableSize.width - Constant.closeButtonRightMargin - Constant.closeButtonSize,
                                  y: Constant.closeButtonTopMargin,
                                  width: Constant.closeButtonSize,
                                  height: Constant.closeButtonSize)
            viewController.view.addSubview(button)
        }
    }

    @objc private func closeButtonTap(_ sender: UIButton) {
        popViewController(animated: true)
        sender.removeFromSuperview()
    }

    @objc private func closeBarButtonTap(_ sender: UIBarButtonItem) {
        popViewController(animated: true)
    }

}
