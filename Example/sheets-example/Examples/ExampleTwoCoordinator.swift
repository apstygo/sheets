//
//  ExampleTwoCoordinator.swift
//  sheets-example
//
//  Created by Artyom Pstygo on 29.08.2019.
//  Copyright © 2019 Artyom Pstygo. All rights reserved.
//

import Foundation
import UIKit
import sheets

class ExampleTwoCoordinator: CoordinatorType {

    private var sheet: SheetController!
    private let viewControllers: [UIViewController] = {
        let one = UIViewController()
        one.view.backgroundColor = .systemRed
        let two = UIViewController()
        two.view.backgroundColor = .systemGreen
        let three = UIViewController()
        three.view.backgroundColor = .systemBlue
        return [one, two, three].map(UINavigationController.init)
    }()

    func start() -> UIViewController {

        // Controllers

        let main = UIViewController()
        main.view.backgroundColor = .systemGroupedBackground
        main.navigationItem.title = "Main"

        let root = viewControllers[0]

        let mainHolder = UINavigationController(rootViewController: main)
        mainHolder.navigationBar.prefersLargeTitles = true

        let sheet = SheetController(mainViewController: mainHolder,
                                    rootViewController: root,
                                    anchors: [.defaultExpanded, .pointsFromBottom(200)])
        self.sheet = sheet

        // Actions

        let cycleButton = UIBarButtonItem(barButtonSystemItem: .refresh,
                                          target: self,
                                          action: #selector(setControllers))
        main.navigationItem.rightBarButtonItem = cycleButton

        return sheet
    }

    private var flag = true
    @objc
    private func setControllers() {
        if flag {
            sheet.setViewControllers(viewControllers, animated: true)
        } else {
            sheet.setViewControllers(viewControllers.reversed(), animated: true)
        }
        flag.toggle()
    }

}
