//
//  UtilityExtensions.swift
//  sheets
//
//  Created by Artyom Pstygo on 16.08.2019.
//  Copyright © 2019 Artyom Pstygo. All rights reserved.
//

#if os(iOS)

import UIKit

extension UIGestureRecognizer.State: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .began:
            return "began"
        case .changed:
            return "changed"
        case .cancelled:
            return "cancelled"
        case .ended:
            return "ended"
        case .failed:
            return "failed"
        case .possible:
            return "possible"
        @unknown default:
            return "unknown"
        }
    }
}

#endif
