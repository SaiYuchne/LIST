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
        chosenRow = indexPath.row
        print("chosenRow: \(chosenRow!)")
        performSegue(withIdentifier: "goToOrginalFavList", sender: self)
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
                tableView.deleteRows(at: [indexPath], with: .fade)
                tableView.reloadData()
            }
            alert.addAction(no)
            alert.addAction(yes)
            present(alert, animated: true, completion: nil)
        }
    }
    
    private func deleteFavListFromDatabase(itemID: String) {
        ref.child("FavouriteList").child(user.userID).child(itemID).removeValue()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToOrginalFavList" {
            if let destination = segue.destination as? SingleFavouriteListViewController {
                print("prepare for segue: goToOrginalFavList")
                print("listName: \(listNames[chosenRow!])")
                destination.listID = listIDs[chosenRow!]
                print("listID: \(listIDs[chosenRow!])")
                ref.child("ListItem").child(listIDs[chosenRow!]).queryOrdered(byChild: "creationDays").observeSingleEvent(of: .value, with: { (snapshot) in
                    destination.goalData.removeAll()
                    if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                        for snap in snapshots {
                            if let itemInfo = snap.value as? [String: Any] {
                                let itemID = snap.key
                                destination.goalData.append(SingleFavouriteListViewController.cellData(opened: false, itemID: itemID, title: itemInfo["content"] as! String, subgoalID: [String](), sectionData: [String]()))
                                
                                // retrive subgoal info
                                self.ref.child("Subgoal").child(itemID).queryOrdered(byChild: "creationDays").observeSingleEvent(of: .value, with: { (snapshot) in
                                    if destination.goalData.count > 0 {
                                        destination.goalData[destination.goalData.count - 1].subgoalID.removeAll()
                                        destination.goalData[destination.goalData.count - 1].sectionData.removeAll()
                                    }
                                    
                                    if let subsnapshots = snapshot.children.allObjects as? [DataSnapshot] {
                                        for subsnap in subsnapshots {
                                            if let subItemInfo = subsnap.value as?[String: Any] {
                                                destination.goalData[destination.goalData.count - 1].subgoalID.append(subsnap.key)
                                                
                                                destination.goalData[destination.goalData.count - 1].sectionData.append(subItemInfo["content"] as! String)
                                            }
                                        }
                                    } // end subgoal info retrival
                                    
                                })
                            } // if itemInfo as [String: Any]
                        } // end list item info retrival
                    }
                    
                    destination.tableView.reloadData()
                })
            }
        }
    }
}
