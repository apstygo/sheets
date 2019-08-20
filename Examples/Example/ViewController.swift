//
//  ViewController.swift
//  SheetController
//
//  Created by Artyom Pstygo on 15.08.2019.
//  Copyright © 2019 Artyom Pstygo. All rights reserved.
//

import UIKit
import SheetController

class ViewController: UIViewController, UITableViewDataSource {

    private var sheet: SheetController!

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let mainTable = UITableViewController()
        mainTable.tableView.dataSource = self

        let rootTable = UITableViewController()
        rootTable.tableView.dataSource = self
        rootTable.tableView.rowHeight = 88

        presentTestControllers(root: rootTable, main: mainTable)
    }

    private func presentTestControllers(root: UIViewController, main: UIViewController) {
        root.navigationItem.title = "Root"
        main.navigationItem.title = "Main"

        let rootHolder = UINavigationController(rootViewController: root)
        let mainHolder = UINavigationController(rootViewController: main)
        mainHolder.navigationBar.prefersLargeTitles = true

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTap(_:)))
        root.navigationItem.rightBarButtonItem = addButton

        let switchButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(switchButtonTap(_:)))
        main.navigationItem.rightBarButtonItem = switchButton

        let sheet = SheetController(mainViewController: mainHolder, rootViewController: rootHolder)
        self.sheet = sheet

        sheet.tabBarItem = UITabBarItem(tabBarSystemItem: .featured, tag: 0)
        let tabBarController = UITabBarController()
        tabBarController.setViewControllers([sheet], animated: false)
        tabBarController.modalPresentationStyle = .overCurrentContext
        present(tabBarController, animated: false)
    }

    @objc private func addButtonTap(_ sender: UIBarButtonItem) {
        sheet.pushViewController(UIViewController(), animated: true)
    }

    private var counter = 1
    @objc private func switchButtonTap(_ sender: UIBarButtonItem) {
        let anchors: [[Anchor]] = [[.pointsFromTop(20), .pointsFromBottom(44)],
                                   [.pointsFromTop(200), .pointsFromBottom(200)]]
        sheet.setAnchors(anchors[counter % 2], animated: true, snapTo: 1)
        counter += 1
    }

    // MARK: - UITableViewDataSource

    static let count = 100

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ViewController.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = String(indexPath.item + 1)
        return cell
    }

}
