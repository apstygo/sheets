//
//  ExampleThreeCoordinator.swift
//  sheets-example
//
//  Created by Artyom Pstygo on 22.09.2019.
//  Copyright © 2019 Artyom Pstygo. All rights reserved.
//

import Foundation
import UIKit
import sheets

class ExampleThreeCoordinator: CoordinatorType {

    private var root: UIViewController?

    private let transitioningDelegate = AppStoreTransitioningDelegate()

    func start() -> UIViewController {
        let viewController = UIViewController()
        viewController.navigationItem.title = "Root"
        viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Present",
                                                                           style: .plain,
                                                                           target: self,
                                                                           action: #selector(handlePresentButtonTap))
        self.root = viewController

        return UINavigationController(rootViewController: viewController)
    }

    @objc private func handlePresentButtonTap() {
        let presentedController = CustomPresentedController()

        presentedController.modalPresentationStyle = .custom
        presentedController.transitioningDelegate = transitioningDelegate

        root?.present(presentedController, animated: true)
    }

    @objc private func handleCloseButtonTap() {
        root?.dismiss(animated: true)
    }

}

class CustomPresentedController: ScrollableTableViewController {

    private let count = 100

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = "\(indexPath.row + 1)"
        return cell
    }
    
}
