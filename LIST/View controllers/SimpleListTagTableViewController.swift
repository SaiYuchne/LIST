//
//  SimpleListTagTableViewController.swift
//  LIST
//
//  Created by 蔡雨倩 on 26/07/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import UIKit
import FirebaseDatabase

class SimpleListTagTableViewController: UITableViewController {

    let ref = Database.database().reference()
    var listID: String?
    let user = LISTUser()
    
    var cellTitle = [String]()
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellTitle.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userTagCell", for: indexPath)
        cell.textLabel?.text = cellTitle[indexPath.row]
        return cell
    }
}
