//
//  TagCollectionTableViewController.swift
//  LIST
//
//  Created by 蔡雨倩 on 14/06/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import UIKit
import FirebaseDatabase

class TagCollectionTableViewController: UITableViewController {

    let ref = Database.database().reference()
    var listID: String?
    
    private var cellTitle = ["Animal", "Cat", "Clothes", "Diet", "Family", "Fashion", "Food", "Love", "Romance", "Sports", "Study", "Travel", "YOLO"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellTitle.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "systemTagCell", for: indexPath)
        cell.textLabel?.text = cellTitle[indexPath.row]
        cell.detailTextLabel?.text = ""
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            if cell.detailTextLabel?.text == "" {
                cell.detailTextLabel?.text = "✔️"
                // add the tag in the database
                ref.child("List").child(listID!).child("tag").observeSingleEvent(of: .value, with: { (snapshot) in
                    if var tags = snapshot.value as? [String] {
                        tags.append(self.cellTitle[indexPath.row])
                        self.ref.child("List").child(self.listID!).child("tag").setValue(tags)
                    }
                })
            } else {
                cell.detailTextLabel?.text = ""
                // delete the tag in the database
               let tagToBeDeleted = cellTitle[indexPath.row]
                ref.child("List").child(listID!).child("tag").observeSingleEvent(of: .value, with: { (snapshot) in
                    if var tags = snapshot.value as? [String] {
                        var tagIndex = -1
                        for index in tags.indices {
                            tagIndex += 1
                            if tags[index] == tagToBeDeleted {
                                break
                            }
                        }
                        tags.remove(at: tagIndex)
                    }
                })
            }
        }
    }

    // MARK: database operations
    func getTableViewDataFromDatabase() {
        let systemTagRef = ref.child("Tag").queryOrdered(byChild: "tagName")
        systemTagRef.observeSingleEvent(of: .value) { (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                for snap in snapshots{
                    let tempData = snap.value as? Dictionary<String, Any>
                    self.cellTitle.append(tempData!["tagName"] as! String)
                }
            }
        }
    }
}
