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
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            selectedTag = cell.textLabel!.text!
            performSegue(withIdentifier: "goToInspirationPoolWithTag", sender: self)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToInspirationPoolWithTag" {
            if let destination = segue.destination as? InspirationPoolViewController {
                destination.tag = selectedTag!
                destination.isTagSpecific = true
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
                    self.tags.append(tempData!["tagName"] as! String)
                }
            }
        }
    }

}
