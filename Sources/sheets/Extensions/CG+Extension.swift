//
//  CG+Extension.swift
//  sheets
//
//  Created by Artyom Pstygo on 16.08.2019.
//  Copyright © 2019 Artyom Pstygo. All rights reserved.
//

import Foundation
import CoreGraphics

extension CGRect {
    var minXminY: CGPoint {
        return CGPoint(x: minX, y: minY)
    }

    var minXmaxY: CGPoint {
        return CGPoint(x: minX, y: maxY)
    }

    var maxXminY: CGPoint {
        return CGPoint(x: maxX, y: minY)
    }

    var maxXmaxY: CGPoint {
        return CGPoint(x: maxX, y: maxY)
    }
}

extension CGPoint {
    func offsetBy(dx: CGFloat, dy: CGFloat) -> CGPoint {
        return CGPoint(x: x + dx, y: y + dy)
    }
}
