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

    public weak var delegate: ScrollableDelegate?
    public var autoDeselect = true

    // MARK: - UIScrollViewDelegate

    open override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.scrollableWillBeginDragging?(scrollView)
    }

    open override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.scrollableDidScroll?(scrollView)
    }

    open override func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                                 withVelocity velocity: CGPoint,
                                                 targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        delegate?.scrollableWillEndDragging?(scrollView,
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

    public weak var delegate: ScrollableDelegate?

    // MARK: - UIScrollViewDelegate

    open override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.scrollableWillBeginDragging?(scrollView)
    }

    open override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.scrollableDidScroll?(scrollView)
    }

    open override func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                                 withVelocity velocity: CGPoint,
                                                 targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        delegate?.scrollableWillEndDragging?(scrollView,
                                             withVelocity: velocity,
                                             targetContentOffset: targetContentOffset)
    }

}

#endif
