//
//  Scrollable.swift
//  sheets
//
//  Created by Artyom Pstygo on 15.08.2019.
//  Copyright © 2019 Artyom Pstygo. All rights reserved.
//

#if os(iOS)

import UIKit

public protocol ScrollableDelegate: class {
    func scrollableDidScroll(_ scrollView: UIScrollView)
    func scrollableWillBeginDragging(_ scrollView: UIScrollView)
    func scrollableWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>)
}

public protocol Scrollable: class {
    var delegate: ScrollableDelegate? { get set }
}

#endif
