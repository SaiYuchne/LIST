//
//  SystemTagCollectionTableViewController.swift
//  LIST
//
//  Created by 蔡雨倩 on 12/07/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import UIKit
import FirebaseDatabase

class SystemTagCollectionTableViewController: UITableViewController, UISearchResultsUpdating {

    let ref = Database.database().reference()
    var listID: String?
    var selectedTag: String?
    
    private var tags = ["Animal", "Arts", "Diet", "Family", "Food", "Hobby", "Life", "Mood", "Romance", "Skill", "Sports", "Study", "Travel", "Work", "YOLO"]
    private var filteredTags = [String]()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            selectedTag = cell.textLabel!.text!
            if shouldPerformSegue(withIdentifier: "goToInspirationPoolWithTag") {
                print("performing segue..")
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
    
    func shouldPerformSegue(withIdentifier identifier: String) -> Bool {
        var shouldPerform = true
        if identifier == "goToInspirationPoolWithTag" {
            ref.child("SmallInspirationPool").child(selectedTag!).observeSingleEvent(of: .value, with: { (snapshot) in
                if !snapshot.exists() {
                    shouldPerform = false
                    self.presentInvalidTagAlert()
                } else {
                    self.performSegue(withIdentifier: "goToInspirationPoolWithTag", sender: self)
                }
            })
        }
        
        print("shoudPerform = \(shouldPerform)")
        return shouldPerform
    }
    
    func presentInvalidTagAlert() {
        let alert = UIAlertController(title: "Sorry", message: "There is no random wish under this tag.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToInspirationPoolWithTag" {
            if let destination = segue.destination as? InspirationPoolViewController {
                destination.selectedTag = selectedTag!
                destination.isTagSpecific = true
                ref.child("SmallInspirationPool").child(selectedTag!).observeSingleEvent(of: .value, with: { (snapshot) in
                    destination.smallWishPool.removeAll()
                    if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                        for snap in snapshots {
                            print("newCell initialized")
                            let itemInfo = snap.value as! [String: String]
                            let newCell = InspirationPoolViewController.cellData(itemID: snap.key, content: itemInfo["content"]!, listID: itemInfo["listID"]!, tags: [self.selectedTag!])
                            destination.smallWishPool.append(newCell)
                        }
                    }
                })
            }
        }
    }

}
