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
    var listTags = [String]()
    let user = LISTUser()
    var participantID = [String]()
    var isPrivate = false
    
    var tags = [String]()
    private var filteredTags = [String]()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filteredTags = tags
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        self.tableView.tableHeaderView = searchController.searchBar
        
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "systemTagCell", for: indexPath) as! SystemTagTableViewCell
        cell.tagLabel.text = filteredTags[indexPath.row]
        if listTags.contains(filteredTags[indexPath.row]) {
            cell.stateLabel.text = "✔️"
        } else {
            cell.stateLabel.text = " "
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? SystemTagTableViewCell {
            if cell.stateLabel.text == " " {
                cell.stateLabel.text = "✔️"
                print("\(filteredTags[indexPath.row]) has been chosen")
                listTags.append(filteredTags[indexPath.row])
                // add the tag in the database
                addTagInDatabase(row: indexPath.row)
            } else {
                print("\(filteredTags[indexPath.row]) has been chosen")
                cell.stateLabel.text = " "
                listTags.remove(at: listTags.index(of: filteredTags[indexPath.row])!)
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
    
    private func addTagInDatabase(row: Int) {
        let selectedTag = filteredTags[row]
        // change the list settings
        print("add tag in list setting")
        ref.child("List").child(listID!).child("tag").child(selectedTag).setValue(selectedTag)
        
        // update the app's tag system
        ref.child("Tag").child("tags").child(selectedTag).child("listCount").observeSingleEvent(of: .value) { (snapshot) in
            let listCount = snapshot.value as! Int
            self.ref.child("Tag").child("tags").child(selectedTag).child("listCount").setValue(listCount + 1)
        }
        ref.child("Tag").child("tags").child(selectedTag).child("listIDs").child(listID!).setValue(listID!)
        // update the participants' TagList
        ref.child("List").child(listID!).child("listTitle").observeSingleEvent(of: .value) { (snapshot) in
            if let listTitle = snapshot.value as? String {
                for person in self.participantID {
                    self.ref.child("TagList").child(person).child(selectedTag).child(self.listID!).setValue(listTitle)
                }
            }
        }
        
        // update Inspiration pool if necessary
        // executed only when the privacy level meets the requirement
        ref.child("List").child(listID!).child("privacy").observeSingleEvent(of: .value) { (snapshot) in
            let privacy = snapshot.value as! String
            if privacy != "friends" && privacy != "only me" {
                self.ref.child("ListItem").child(self.listID!).observeSingleEvent(of: .value) { (snapshot) in
                    if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                        for snap in snapshots {
                            let itemID = snap.key
                            self.ref.child("InspirationPool").child(itemID).observeSingleEvent(of: .value, with: { (snapshot) in
                                if !snapshot.exists() {
                                    let itemInfo = snap.value as! [String: Any]
                                    let addInfo = ["content": itemInfo["content"] as! String, "listID": self.listID!]
                                    self.ref.child("InspirationPool").child(itemID).setValue(addInfo)
                                    // update SmallInspirationPool
                                    self.ref.child("SmallInspirationPool").child(selectedTag).child(itemID).setValue(addInfo)
                                }
                            })
                        }
                    }
                }
            } // the privacy level meets the requirement
        }
    }
    
    private func deleteTagInDatabase (tagToBeDeleted: String) {
        // change the list settings
        ref.child("List").child(listID!).child("tag").child(tagToBeDeleted).removeValue()
        
        // update the app's tag system
        ref.child("Tag").child("tags").child("\(tagToBeDeleted)").child("listCount").observeSingleEvent(of: .value) { (snapshot) in
            let listCount = snapshot.value as! Int
            self.ref.child("Tag").child("tags").child(tagToBeDeleted).child("listCount").setValue(listCount - 1)
        }
        ref.child("Tag").child("tags").child(tagToBeDeleted).child("listIDs").child(listID!).removeValue()
        // update the participants' TagList
        for person in participantID {
           ref.child("TagList").child(person).child(tagToBeDeleted).child(listID!).removeValue()
        }
        
        // update Inspiration Pool if necessary
        if listTags.count == 0 {
            ref.child("ListItem").child(self.listID!).observeSingleEvent(of: .value) { (snapshot) in
                if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                    for snap in snapshots {
                        let itemID = snap.key
                        self.ref.child("InspirationPool").child(itemID).removeValue()
                        // update SmallInspirationPool
                        self.ref.child("SmallInspirationPool").child(tagToBeDeleted).child(itemID).removeValue()
                    }
                }
            }
        }
    }
}
