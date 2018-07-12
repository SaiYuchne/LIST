//
//  TagCollectionTableViewController.swift
//  LIST
//
//  Created by 蔡雨倩 on 14/06/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import UIKit
import FirebaseDatabase

class TagCollectionTableViewController: UITableViewController, UISearchResultsUpdating {

    let ref = Database.database().reference()
    var listID: String?
    
    private var tags = ["Animal", "Cat", "Clothes", "Diet", "Family", "Fashion", "Food", "Love", "Romance", "Sports", "Study", "Travel", "YOLO"]
    private var filteredTags = [String]()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getTableViewDataFromDatabase()
        
        filteredTags = tags
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        self.tableView.tableHeaderView = searchController.searchBar
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "systemTagCell")
        self.tableView.reloadData()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredTags.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "systemTagCell", for: indexPath)
        cell.textLabel?.text = filteredTags[indexPath.row]
        cell.detailTextLabel?.text = ""
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            if cell.detailTextLabel?.text == "" {
                cell.detailTextLabel?.text = "✔️"
                // add the tag in the database
                addTagInDatabase(row: indexPath.row)
            } else {
                cell.detailTextLabel?.text = ""
                // delete the tag in the database
               let tagToBeDeleted = filteredTags[indexPath.row]
                deleteTagInDatabase(tagToBeDeleted: tagToBeDeleted)
            }
        }
    }

    func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text! == "" {
            filteredTags = tags
        } else {
            filteredTags = tags.filter({ $0.lowercased().contains(searchController.searchBar.text!.lowercased())})
        }
        self.tableView.reloadData()
    }
    
    // MARK: database operations
    func getTableViewDataFromDatabase() {
        let systemTagRef = ref.child("Tag").queryOrdered(byChild: "tagName")
        systemTagRef.observeSingleEvent(of: .value) { (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                for snap in snapshots{
                    let tempData = snap.value as? Dictionary<String, Any>
                    self.tags.append(tempData!["tagName"] as! String)
                }
            }
        }
    }
    
    private func addTagInDatabase(row: Int) {
        // change the list settings
        ref.child("List").child(listID!).child("tag").observeSingleEvent(of: .value, with: { (snapshot) in
            if var tags = snapshot.value as? [String] {
                tags.append(self.tags[row])
                self.ref.child("List").child(self.listID!).child("tag").setValue(tags)
            }
        })
        
        // update the app's tag system
        ref.child("Tag").child("tags").child(tags[row]).child("listCount").observeSingleEvent(of: .value) { (snapshot) in
                let listCount = snapshot.value as! Int
                self.ref.child("Tag").child("tags").child(self.tags[row]).child("listCount").setValue(listCount + 1)
        }
        ref.child("Tag").child("tags").child(tags[row]).child("listIDs").child(listID!).setValue(listID!)
    }
    
    private func deleteTagInDatabase (tagToBeDeleted: String) {
       // change the list settings
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
       // update the app's tag system
        ref.child("Tag").child("tags").child("tagToBeDeleted").child("listCount").observeSingleEvent(of: .value) { (snapshot) in
            let listCount = snapshot.value as! Int
            self.ref.child("Tag").child("tags").child("tagToBeDeleted").child("listCount").setValue(listCount - 1)
        }
       
        ref.child("Tag").child("tags").child("tagToBeDeleted").child("listIDs").child(listID!).removeValue()
    }
}
