//
//  SimpleDataSource.swift
//  sheets-example
//
//  Created by Artyom Pstygo on 29.08.2019.
//  Copyright © 2019 Artyom Pstygo. All rights reserved.
//

import Foundation
import UIKit

class SimpleDataSource<T>: NSObject, UITableViewDataSource {

    private let objects: [T]

    init(objects: [T]) {
        self.objects = objects
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = "\(objects[indexPath.row])"
        return cell
    }

}
