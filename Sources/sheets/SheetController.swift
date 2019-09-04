//
//  SheetController.swift
//  sheets
//
//  Created by Artyom Pstygo on 15.08.2019.
//  Copyright © 2019 Artyom Pstygo. All rights reserved.
//

#if os(iOS)

import UIKit

public class SheetController: UIViewController, ScrollableDelegate {

    private enum GestureState {
        case idle
        case dragging(initialOrigin: CGFloat)
    }

    private enum ContentState {
        case idle
        case dragging(lastContentOffset: CGPoint)
    }

    private enum Location {
        case top
        case middle
        case bottom
    }

    private enum TransitionType {
        case push
        case pop
    }

    // MARK: - Public: Options

    public var isExpandGestureEnabled = true
    public var isCollapseGestureEnabled = true
    public var cancelsTouchesInCollapsedState = true {
        didSet { updateContentTapCancelsTouches() }
    }
    public var hidesTabBarUponExpansion = true
    public var closeButtonImage: UIImage?

    // MARK: - Private: State

    private var gestureState: GestureState = .idle
    private var contentState: ContentState = .idle
    private var currentLocation: Location = .bottom {
        didSet { updateContentTapCancelsTouches() }
    }
    private var appearsFirstTime = true
    private var tabBarIsHidden = false
    private weak var currentScrollable: Scrollable?
    private var closeButtons = [UIButton]()
    private var modifiedNavigationItemControllers = [UIViewController]()

    // MARK: - Private: Gesture Recognizers

    private lazy var panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
    private lazy var contentTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleContentTap(_:)))
    private lazy var dimmingViewTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDimmingViewTap(_:)))

    // MARK: - Private: Views

    private lazy var contentView: UIView = {
        let content = UIView()
        content.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        content.layer.cornerRadius = Constant.cornerRadius
        content.layer.masksToBounds = true
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
        dimming.alpha = 0
        return dimming
    }()

    // MARK: - Initializers

    public init(mainViewController: UIViewController, rootViewController: UIViewController, anchors: [Anchor]? = nil) {
        self.mainViewController = mainViewController
        self.viewControllers = [rootViewController]
        self.anchors = anchors ?? [.defaultExpanded, .defaultCollapsed]

        super.init(nibName: nil, bundle: nil)

        layoutMainController()
        layoutRootController()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public: Anchors

    public private(set) var anchors: [Anchor]

    public func setAnchors(_ anchors: [Anchor], animated: Bool, snapTo index: Int = 0) {
        self.anchors = anchors
        adjustMainVCSafeAreaInsets()
        snapToAnchor(atIndex: index, animated: animated)
    }

    public func snapToAnchor(atIndex index: Int, animated: Bool) {
        assert(index < anchorPoints.count, "Cannot snap to anchor, because index is out of bounds")
        moveOrigin(to: anchorPoints[index], animated: animated)
    }

    public func expand(animated: Bool) {
        snapToAnchor(atIndex: 0, animated: animated)
    }

    public func collapse(animated: Bool) {
        snapToAnchor(atIndex: anchors.count - 1, animated: animated)
    }

    // MARK: - Public: View Controllers

    public private(set) var mainViewController: UIViewController
    public private(set) var viewControllers: [UIViewController]

    public var topViewController: UIViewController {
        return viewControllers.last!
    }

    public func pushViewController(_ viewController: UIViewController, animated: Bool) {
        cycle(fromViewController: topViewController,
              toViewController: viewController,
              transitionType: .push,
              animated: animated,
              addCloseButton: true)
        viewControllers.append(viewController)
    }

    @discardableResult
    public func popViewController(animated: Bool) -> UIViewController? {
        guard viewControllers.count > 1 else { return nil }

        let from = viewControllers.popLast()!
        let to = viewControllers.last!
        cycle(fromViewController: from,
              toViewController: to,
              transitionType: .pop,
              animated: animated,
              addCloseButton: false)

        return from
    }

    @discardableResult
    public func popToRootViewController(animated: Bool) -> [UIViewController]? {
        return popToViewController(viewControllers[0], animated: animated)
    }

    @discardableResult
    public func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        assert(viewControllers.contains(viewController),
               "View controller must be inside SheetController's viewControllers array")
        guard viewController != topViewController,
            let vcIndex = viewControllers.firstIndex(of: viewController) else { return nil }

        cycle(fromViewController: topViewController,
              toViewController: viewController,
              transitionType: .pop,
              animated: animated,
              addCloseButton: false)

        let vcsToReturn = Array(viewControllers[(vcIndex + 1)...])
        viewControllers = Array(viewControllers[...vcIndex])
        return vcsToReturn
    }

    public func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        assert(!viewControllers.isEmpty, "SheetController can't display an empty array of controllers")

        var transitionType: TransitionType?
        switch self.viewControllers.firstIndex(of: viewControllers.last!) {
        case nil:
            transitionType = .push
        case self.viewControllers.count - 1:
            transitionType = nil
        default:
            transitionType = .pop
        }

        // remove all close buttons and properly re-add them
        disposeOfCloseButtons()
        if viewControllers.count > 1 {
            viewControllers[1...].forEach { self.addCloseButton(toViewController: $0) }
        }

        if let transitionType = transitionType {
            cycle(fromViewController: topViewController,
                  toViewController: viewControllers.last!,
                  transitionType: transitionType,
                  animated: animated,
                  addCloseButton: false)
        }

        self.viewControllers = viewControllers
    }

    // MARK: - UIViewController Lifecycle

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

        // Gesture recognizer bindings

        contentView.addGestureRecognizer(panRecognizer)
        contentView.addGestureRecognizer(contentTapRecognizer)

        dimmingViewTapRecognizer.cancelsTouchesInView = false
        dimmingEffectView.addGestureRecognizer(dimmingViewTapRecognizer)

        // TabBar hiding fix

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleAppWillEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if appearsFirstTime {
            appearsFirstTime = false
            origin = anchorPoints.max()!
            adjustContainerSize(targetOrigin: anchorPoints.min()!)
            adjustMainVCSafeAreaInsets()
        }
    }

    @objc private func handleAppWillEnterForeground() {
        if tabBarIsHidden, let tabBarController = tabBarController {
            let tabBar = tabBarController.tabBar
            tabBar.frame.origin.y += tabBar.frame.size.height
        }
    }

    // MARK: - Gesture Handling

    @objc private func handlePan(_ sender: UIPanGestureRecognizer) {
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
        case .possible: break
        @unknown default: break
        }
    }

    @objc private func handleContentTap(_ sender: UITapGestureRecognizer) {
        if isExpandGestureEnabled,
           currentLocation == .bottom,
           sender.location(in: contentView).y < headerHeight || cancelsTouchesInCollapsedState {
            expand(animated: true)
        }
    }

    @objc private func handleDimmingViewTap(_ sender: UITapGestureRecognizer) {
        if isCollapseGestureEnabled, currentLocation == .top {
            collapse(animated: true)
        }
    }

    private func updateContentTapCancelsTouches() {
        contentTapRecognizer.cancelsTouchesInView = currentLocation == .bottom && cancelsTouchesInCollapsedState
    }

    // MARK: - Position Adjustment and Animation

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
        mainViewController.additionalSafeAreaInsets = UIEdgeInsets(top: 0,
                                                                    left: 0,
                                                                    bottom: additionalBottomInset,
                                                                    right: 0)
    }

    private func moveOrigin(to newOriginY: CGFloat,
                            animated: Bool,
                            velocity: CGFloat = 0,
                            completion: ((Bool) -> Void)? = nil) {
        // update state
        switch newOriginY {
        case anchorPoints.first!:
            currentLocation = .top
        case anchorPoints.last!:
            currentLocation = .bottom
        default:
            currentLocation = .middle
        }

        // hide tab bar in parallel
        setTabBarHidden(currentLocation == .top, animated: animated)

        // animate movement
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

    private func trimTargetScrollableOrigin(_ target: CGFloat) -> CGFloat {
        if target < anchorPoints.min()! {
            return anchorPoints.min()!
        } else if target > anchorPoints.max()! {
            return anchorPoints.max()!
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

    private func setTabBarHidden(_ hide: Bool, animated: Bool) {
        guard hidesTabBarUponExpansion,
            let tabBarController = tabBarController,
            hide != tabBarIsHidden else { return }

        let currentFrame = tabBarController.tabBar.frame
        var newFrame = currentFrame
        var options: UIView.AnimationOptions = [.beginFromCurrentState]

        if hide {
            newFrame.origin.y += newFrame.size.height
            options.formUnion(.curveEaseIn)
        } else {
            newFrame.origin.y -= newFrame.size.height
            options.formUnion(.curveEaseOut)
        }

        let animations = {
            tabBarController.tabBar.frame = newFrame
        }

        UIView.animate(withDuration: animated ? Constant.tabBarAnimationDuration : 0,
                       delay: 0,
                       options: options,
                       animations: animations,
                       completion: nil)

        tabBarIsHidden = hide
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

            origin = trimTargetScrollableOrigin(origin + diff)

            scrollView.showsVerticalScrollIndicator = false

        } else {
            scrollView.showsVerticalScrollIndicator = true
        }
    }

    public func scrollableWillEndDragging(_ scrollView: UIScrollView,
                                          withVelocity velocity: CGPoint,
                                          targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        contentState = .idle

        guard origin > anchorPoints.min()! else { setTabBarHidden(true, animated: true); return }

        /// Stop scrolling
        targetContentOffset.pointee = scrollView.contentOffset

        moveOriginToTheNearestAnchor(withVelocity: -velocity.y)
    }

    // MARK: - Layout

    private func layoutMainController() {
        addAsChild(mainViewController) { mainView in
            mainView.frame = view.bounds
            view.insertSubview(mainView, belowSubview: dimmingEffectView)
        }
    }

    private func layoutRootController() {
        let rootController = viewControllers[0]
        addAsChild(viewControllers[0]) { rootView in
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
        return anchors.map { $0.offset(inFrame: availableFrame) }.sorted()
    }

    private var outOfViewFrame: CGRect {
        return CGRect(origin: contentView.bounds.minXmaxY, size: contentView.bounds.size)
    }

    private var headerHeight: CGFloat {
        if let navController = topViewController as? UINavigationController {
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
                       animated: Bool,
                       addCloseButton: Bool) {
        oldVC.willMove(toParent: nil)
        addChild(newVC)

        let newVCStartFrame: CGRect
        let newVCEndFrame: CGRect
        let oldVCEndFrame: CGRect
        let options: UIView.AnimationOptions

        switch transitionType {
        case .push:
            newVCStartFrame = outOfViewFrame
            newVCEndFrame = contentView.bounds
            oldVCEndFrame = contentView.bounds
            options = .curveEaseOut

        case .pop:
            newVCStartFrame = contentView.bounds
            newVCEndFrame = contentView.bounds
            oldVCEndFrame = outOfViewFrame
            options = .curveEaseIn
        }

        newVC.view.frame = newVCStartFrame
        switch transitionType {
        case .push:
            contentView.insertSubview(newVC.view, aboveSubview: oldVC.view)
        case .pop:
            contentView.insertSubview(newVC.view, belowSubview: oldVC.view)
        }

        if addCloseButton {
            self.addCloseButton(toViewController: newVC)
        }

        contentView.isUserInteractionEnabled = false

        let animations = {
            newVC.view.frame = newVCEndFrame
            oldVC.view.frame = oldVCEndFrame
        }

        let completion = { (_: Bool) -> Void in
            oldVC.removeFromParent()
            newVC.didMove(toParent: self)
            self.contentView.isUserInteractionEnabled = true
        }

        UIView.animate(withDuration: animated ? Constant.originAnimationDuration : 0,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 0,
                       options: options,
                       animations: animations,
                       completion: completion)

        bindAsScrollable(viewController: newVC)
    }

    // MARK: - Misc

    private func addCloseButton(toViewController viewController: UIViewController) {
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

            modifiedNavigationItemControllers.append(navigationController.viewControllers[0])

        } else {
            let button = UIButton()
            button.addTarget(self, action: #selector(closeButtonTap(_:)), for: .touchUpInside)

            var image = closeButtonImage
            if #available(iOS 13, *) {
                button.imageView?.tintColor = .systemGray3
                button.imageView?.contentMode = .scaleAspectFit
                let largeConfig = UIImage.SymbolConfiguration(textStyle: .title2)
                image = closeButtonImage ?? UIImage(systemName: "xmark.circle.fill", withConfiguration: largeConfig)
            }
            button.setImage(image, for: .normal)

            let availableSize = viewController.view.bounds.size
            button.frame = CGRect(x: availableSize.width - Constant.closeButtonRightMargin - Constant.closeButtonSize,
                                  y: Constant.closeButtonTopMargin,
                                  width: Constant.closeButtonSize,
                                  height: Constant.closeButtonSize)
            viewController.view.addSubview(button)

            closeButtons.append(button)
        }
    }

    private func disposeOfCloseButtons() {
        closeButtons.forEach { $0.removeFromSuperview() }
        closeButtons.removeAll()
        modifiedNavigationItemControllers.forEach { $0.navigationItem.rightBarButtonItem = nil }
        modifiedNavigationItemControllers.removeAll()
    }

    @objc private func closeButtonTap(_ sender: UIButton) {
        popViewController(animated: true)
        sender.removeFromSuperview()
    }

    @objc private func closeBarButtonTap(_ sender: UIBarButtonItem) {
        popViewController(animated: true)
    }

}

private enum Constant {
    static let dimmingEffectViewMaxAlpha: CGFloat = 0.3
    static let primaryMargin: CGFloat = 20
    static let cornerRadius: CGFloat = 10

    static let closeButtonSize: CGFloat = 30
    static let closeButtonTopMargin: CGFloat = 10
    static let closeButtonRightMargin: CGFloat = 10

    static let shadowOffset = CGSize(width: 0, height: 16)
    static let shadowRadius: CGFloat = 16
    static let shadowColor = UIColor.black.cgColor
    static let shadowOpacity: Float = 0.5

    static let defaultSpringDamping: CGFloat = 0.85
    static let originAnimationDuration: TimeInterval = 0.5

    static let tabBarAnimationDuration: TimeInterval = 0.25
}

#endif
