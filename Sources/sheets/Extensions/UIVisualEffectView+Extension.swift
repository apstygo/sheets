//
//  UIVisualEffectView+Extension.swift
//  
//
//  Created by Artyom Pstygo on 28.09.2019.
//

import UIKit

extension UIVisualEffectView {
    static func createBlurView() -> UIVisualEffectView {
        if #available(iOS 13, *) {
            let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
            return blurView
        } else {
            let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
            return blurView
        }
    }
}

