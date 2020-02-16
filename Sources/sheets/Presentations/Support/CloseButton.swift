//
//  CloseButton.swift
//  
//
//  Created by Artyom Pstygo on 16.02.2020.
//

import Foundation
import UIKit

class CloseButton: UIButton {

    private var crossLayer: CAShapeLayer!

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        let frm = CGRect(origin: .zero, size: Constant.size)
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: Constant.blurStyle))
        blurView.frame = frm
        blurView.layer.cornerRadius = Constant.sideLength / 2
        blurView.layer.masksToBounds = true
        blurView.isUserInteractionEnabled = false
        addSubview(blurView)

        let crossLayer = CAShapeLayer()
        self.crossLayer = crossLayer
        crossLayer.frame = frm
        crossLayer.lineCap = .round
        crossLayer.lineWidth = 2
        crossLayer.fillColor = nil
        crossLayer.opacity = 1
        crossLayer.strokeColor = Constant.strokeColor

        let path = UIBezierPath()
        path.move(to: Constant.topLeft)
        path.addLine(to: Constant.bottomRight)
        path.move(to: Constant.topRight)
        path.addLine(to: Constant.bottomLeft)

        crossLayer.path = path.cgPath
        layer.addSublayer(crossLayer)
    }

    override var intrinsicContentSize: CGSize {
        return Constant.size
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        crossLayer.strokeColor = Constant.strokeColor
    }

}

private enum Constant {
    static let sideLength: CGFloat = 30
    static var size: CGSize {
        return CGSize(width: sideLength, height: sideLength)
    }
    static var center: CGPoint {
        return CGPoint(x: sideLength / 2, y: sideLength / 2)
    }

    static let pathConstant: CGFloat = 6
    static var topLeft: CGPoint {
        return center.offsetBy(dx: -pathConstant, dy: -pathConstant)
    }
    static var topRight: CGPoint {
        return center.offsetBy(dx: pathConstant, dy: -pathConstant)
    }
    static var bottomLeft: CGPoint {
        return center.offsetBy(dx: -pathConstant, dy: pathConstant)
    }
    static var bottomRight: CGPoint {
        return center.offsetBy(dx: pathConstant, dy: pathConstant)
    }

    static var blurStyle: UIBlurEffect.Style {
        if #available(iOS 13, *) {
            return .systemMaterial
        } else {
            return .regular
        }
    }
    static var strokeColor: CGColor {
        if #available(iOS 13, *) {
            return UIColor.label.cgColor
        } else {
            return UIColor.black.cgColor
        }
    }
}
