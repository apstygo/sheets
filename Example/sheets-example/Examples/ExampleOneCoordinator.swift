//
//  ExampleOneCoordinator.swift
//  sheets-example
//
//  Created by Artyom Pstygo on 29.08.2019.
//  Copyright © 2019 Artyom Pstygo. All rights reserved.
//

import Foundation
import UIKit
import sheets

class ExampleOneCoordinator: CoordinatorType {

    private let dataSource = SimpleDataSource(objects: Array(1...100))
    private var sheet: SheetController!

    func start() -> UIViewController {

        // Controllers

        let main = UITableViewController()
        main.tableView.dataSource = dataSource
        main.navigationItem.title = "Main"

        let root = ScrollableTableViewController()
        root.tableView.dataSource = dataSource
        root.tableView.rowHeight = 88
        root.navigationItem.title = "Root"

        let rootHolder = UINavigationController(rootViewController: root)
        let mainHolder = UINavigationController(rootViewController: main)
        mainHolder.navigationBar.prefersLargeTitles = true

        let sheet = SheetController(mainViewController: mainHolder, rootViewController: rootHolder)
        self.sheet = sheet

        // Actions

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTap(_:)))
        root.navigationItem.rightBarButtonItem = addButton

        let switchButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(switchButtonTap(_:)))
        main.navigationItem.rightBarButtonItem = switchButton

        return sheet
    }

    @objc private func addButtonTap(_ sender: UIBarButtonItem) {
        let innerController = ScrollableTableViewController()
        innerController.navigationItem.title = "Pushed sheet"
        let outerController = UINavigationController(rootViewController: innerController)
        sheet.pushViewController(outerController, animated: true)
    }

    private var counter = 1
    @objc private func switchButtonTap(_ sender: UIBarButtonItem) {
        let anchors: [[Anchor]] = [[.pointsFromTop(20), .pointsFromBottom(44)],
                                   [.pointsFromTop(200), .pointsFromBottom(200)]]
        sheet.setAnchors(anchors[counter % 2], animated: true, snapTo: 1)
        counter += 1
    }

}
