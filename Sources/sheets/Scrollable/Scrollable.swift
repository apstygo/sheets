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
    var delegate: ScrollableDelegate? { get set }
}

#endif
