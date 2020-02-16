//
//  Scrollable.swift
//  sheets
//
//  Created by Artyom Pstygo on 15.08.2019.
//  Copyright © 2019 Artyom Pstygo. All rights reserved.
//

#if os(iOS)

import UIKit

@objc public protocol ScrollableDelegate: class {
    @objc optional func scrollableDidScroll(_ scrollView: UIScrollView)
    @objc optional func scrollableWillBeginDragging(_ scrollView: UIScrollView)
    @objc optional func scrollableWillEndDragging(_ scrollView: UIScrollView,
                                                  withVelocity velocity: CGPoint,
                                                  targetContentOffset: UnsafeMutablePointer<CGPoint>)
}

public protocol Scrollable: class {
    var scrollableDelegate: ScrollableDelegate? { get set }
}

extension UIViewController {
    /// Returns `self` as `Scrollable` if possible or finds the first `Scrollable` inside of `self` (e.g. if `self` is a `UINavigationController`)
    func asScrollable() -> Scrollable? {
        var candidateVC = self
        if let navigationController = candidateVC as? UINavigationController {
            candidateVC = navigationController.viewControllers[0]
        }

        if let scrollable = candidateVC as? Scrollable {
            return scrollable
        }

        return nil
    }
}

#endif
