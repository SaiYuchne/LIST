//
//  ViewFavouriteListViewController.swift
//  LIST
//
//  Created by 蔡雨倩 on 09/07/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ViewFavouriteListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let user = LISTUser()
    let ref = Database.database().reference()
    
    @IBOutlet weak var tableView: UITableView!
    var listIDs = [String]()
    var listNames = [String]()
    var chosenRow: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        getTableViewDataFromDatabase()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favListNameCell", for: indexPath) as! FavListNameTableViewCell
        cell.listNameLabel.text = listNames[indexPath.row]
        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listIDs.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            chosenRow = indexPath.row - 1
            performSegue(withIdentifier: "goToOrginalList", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToOriginalList" {
            if let destination = segue.destination as? SingleFavouriteListViewController {
                destination.listName = listNames[chosenRow!]
                destination.listID = listIDs[chosenRow!]
            }
        }
    }
    
    // MARK: delete list items
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            let alert = UIAlertController(title: "Warning", message: "Delete this favourite list?", preferredStyle: .alert)
            let no = UIAlertAction(title: "No", style: .cancel, handler: nil)
            let yes = UIAlertAction(title: "Yes", style: .default) { (_) in
                // delete data in the database
                self.deleteFavListFromDatabase(itemID: self.listIDs[indexPath.row])
                self.listIDs.remove(at: indexPath.row)
                self.listNames.remove(at: indexPath.row)
                tableView.reloadData()
            }
            alert.addAction(no)
            alert.addAction(yes)
            present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: database operations
    private func getTableViewDataFromDatabase() {
        ref.child("FavouriteList").child(user.userID).observeSingleEvent(of: .value) { (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshots {
                    self.listIDs.append(snap.value as! String)
                    self.listNames.append(snap.key)
                }
            }
        }
    }
    
    private func deleteFavListFromDatabase(itemID: String) {
        ref.child("FavouriteList").child(user.userID).child(itemID).removeValue()
    }
}
