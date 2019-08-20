//
//  Collection+Extension.swift
//  sheets
//
//  Created by Artyom Pstygo on 15.08.2019.
//  Copyright © 2019 Artyom Pstygo. All rights reserved.
//

import Foundation

extension Array where Element: FloatingPoint {
    func nearestElement(to element: Element) -> Element? {
        guard !isEmpty else { return nil }
        guard count > 1 else { return self[0] }

        var candidate = self[0]
        var diff = (element - candidate).magnitude

        for elem in self[1 ..< count] {
            let newDiff = (element - elem).magnitude
            if newDiff < diff {
                diff = newDiff
                candidate = elem
            }
        }

        return candidate
    }
}
