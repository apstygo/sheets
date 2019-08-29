//
//  Anchor.swift
//  sheets
//
//  Created by Artyom Pstygo on 27.08.2019.
//  Copyright © 2019 Artyom Pstygo. All rights reserved.
//

import CoreGraphics

public enum Anchor {
    case ratio(Double)
    case pointsFromTop(CGFloat)
    case pointsFromBottom(CGFloat)

    case defaultExpanded
    case defaultCollapsed

    public func offset(inFrame frame: CGRect) -> CGFloat {
        switch self {
        case let .pointsFromBottom(constant):
            return frame.maxY - constant
        case let .pointsFromTop(constant):
            return frame.minY + constant
        case let .ratio(ratio):
            return frame.minY + CGFloat(ratio) * frame.height
        case .defaultExpanded:
            return frame.minY + Constant.defaultPointsFromTopOffset
        case .defaultCollapsed:
            return frame.maxY - Constant.defaultPointsFromBottomOffset
        }
    }

    private enum Constant {
        static let defaultPointsFromTopOffset: CGFloat = 20
        static let defaultPointsFromBottomOffset: CGFloat = 44
    }

}
