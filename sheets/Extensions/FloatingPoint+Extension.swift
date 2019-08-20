//
//  FloatingPoint+Extension.swift
//  sheets
//
//  Created by Artyom Pstygo on 15.08.2019.
//  Copyright © 2019 Artyom Pstygo. All rights reserved.
//

import Foundation

extension FloatingPoint {

    func project(initialVelocity: Self, decelerationRate: Self) -> Self {
        if decelerationRate >= 1 {
            assert(false)
            return self
        }
        return self + initialVelocity * decelerationRate / (1 - decelerationRate)
    }

}
