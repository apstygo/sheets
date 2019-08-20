//
//  Scrollable.swift
//  sheets
//
//  Created by Artyom Pstygo on 15.08.2019.
//  Copyright © 2019 Artyom Pstygo. All rights reserved.
//

import Foundation
import UIKit

public protocol Scrollable: class {
    var scrollView: UIScrollView? { get }
}

extension UITableViewController: Scrollable {
    public var scrollView: UIScrollView? { return tableView }
}

extension UINavigationController: Scrollable {
    public var scrollView: UIScrollView? {
        if let tableVC = viewControllers.last as? UITableViewController {
            return tableVC.scrollView
        }
        return nil
    }
}
