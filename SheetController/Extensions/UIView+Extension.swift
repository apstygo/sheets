//
//  UIView+Extension.swift
//  SheetController
//
//  Created by Artyom Pstygo on 15.08.2019.
//  Copyright © 2019 Artyom Pstygo. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func firstSubview<T: UIView>(ofType returnType: T.Type) -> T? {
        if let selfAsType = self as? T {
            return selfAsType
        }

        var candidates = subviews
        var stagingCandidates = [UIView]()

        while !candidates.isEmpty {
            for candidate in candidates {
                if let candidateAsType = candidate as? T {
                    return candidateAsType
                }
                stagingCandidates.append(contentsOf: candidate.subviews)
            }
            candidates = stagingCandidates
            stagingCandidates.removeAll()
        }

        return nil
    }
}
