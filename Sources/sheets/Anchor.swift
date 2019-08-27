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
}
