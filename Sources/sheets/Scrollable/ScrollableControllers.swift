//
//  ScrollableControllers.swift
//  sheets
//  
//
//  Created by Artyom Pstygo on 22.08.2019.
//

#if os(iOS)

import UIKit

open class ScrollableTableViewController: UITableViewController, Scrollable {

    public weak var scrollableDelegate: ScrollableDelegate?
    public var autoDeselect = true

    // MARK: - UIScrollViewDelegate

    open override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollableDelegate?.scrollableWillBeginDragging?(scrollView)
    }

    open override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollableDelegate?.scrollableDidScroll?(scrollView)
    }

    open override func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                                 withVelocity velocity: CGPoint,
                                                 targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        scrollableDelegate?.scrollableWillEndDragging?(scrollView,
                                             withVelocity: velocity,
                                             targetContentOffset: targetContentOffset)
    }

    // MARK: - UITableViewDelegate

    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if autoDeselect {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

}

open class ScrollableCollectionViewController: UICollectionViewController, Scrollable {

    public weak var scrollableDelegate: ScrollableDelegate?

    // MARK: - UIScrollViewDelegate

    open override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollableDelegate?.scrollableWillBeginDragging?(scrollView)
    }

    open override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollableDelegate?.scrollableDidScroll?(scrollView)
    }

    open override func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                                 withVelocity velocity: CGPoint,
                                                 targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        scrollableDelegate?.scrollableWillEndDragging?(scrollView,
                                             withVelocity: velocity,
                                             targetContentOffset: targetContentOffset)
    }

}

open class ScrollablePageViewController: UIPageViewController, UIPageViewControllerDelegate, Scrollable {

    public weak var scrollableDelegate: ScrollableDelegate? {
        didSet {
            setDelegateOnScrollable()
        }
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
    }

    open override func setViewControllers(_ viewControllers: [UIViewController]?,
                                          direction: UIPageViewController.NavigationDirection,
                                          animated: Bool,
                                          completion: ((Bool) -> Void)? = nil) {
        super.setViewControllers(
            viewControllers,
            direction: direction,
            animated: animated,
            completion: completion
        )

        setDelegateOnScrollable()
    }

    open func pageViewController(_ pageViewController: UIPageViewController,
                                 didFinishAnimating finished: Bool,
                                 previousViewControllers: [UIViewController],
                                 transitionCompleted completed: Bool) {
        setDelegateOnScrollable()
    }

    private func setDelegateOnScrollable() {
        (viewControllers?.first as? Scrollable)?.scrollableDelegate = scrollableDelegate
    }

}

#endif
