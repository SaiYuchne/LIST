//
//  TagsTableViewController.swift
//  LIST
//
//  Created by 蔡雨倩 on 14/06/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import UIKit
import FirebaseDatabase

class TagsTableViewController: UITableViewController {

    let ref = Database.database().reference()
    var listID: String?
    let user = LISTUser()
    
    var cellTitle = ["Add more tags"]
    
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
        
        if indexPath.row+1 < cellTitle.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "userTagCell", for: indexPath)
            cell.textLabel?.text = cellTitle[indexPath.row]
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "addTagCell", for: indexPath)
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == cellTitle.count - 1 {
            self.performSegue(withIdentifier: "goToTagCollection", sender: self)
        }
    }
 
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row + 1 < cellTitle.count{
            return true
        }
        return false
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            if indexPath.row+1 != tableView.numberOfRows(inSection: 0){
                let alert = UIAlertController(title: "Warning", message: "Delete this tag?", preferredStyle: .alert)
                let no = UIAlertAction(title: "No", style: .cancel, handler: nil)
                let yes = UIAlertAction(title: "Yes", style: .default) { (_) in
                    // remove the tag from the database
                    self.removeTagFromDatabase(tag: self.cellTitle[indexPath.row])

                    self.cellTitle.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                }
                alert.addAction(no)
                alert.addAction(yes)
                present(alert, animated: true, completion: nil)
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToTagCollection"{
            if let destination = segue.destination as? TagCollectionTableViewController{
                destination.listID = listID
                ref.child("Tag").child("tags").observe(.value, with: { (snapshot) in
                    destination.tags.removeAll()
                    if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                        for snap in snapshots {
                            destination.tags.append(snap.key)
                            print("\(snap.key) added")
                        }
                        self.ref.child("List").child(self.listID!).child("tag").queryOrdered(byChild: "tagName").observe(.value, with: { (snapshot) in
                            destination.listTags.removeAll()
                            if snapshot.exists() {
                                print("list Tag does exist")
                                if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                                    for snap in snapshots {
                                        destination.listTags.append(snap.key)
                                    }
                                }
                            } else {
                                print("list Tag does not exist")
                            }
                        })
                    }
                    destination.tableView.reloadData()
                })
            }
        }
    }
    
    func removeTagFromDatabase(tag: String) {
        ref.child("List").child(listID!).child("tag").child(tag).removeValue()
        // update the app's tag system
        ref.child("Tag").child("tags").child(tag).child("listCount").observeSingleEvent(of: .value) { (snapshot) in
            let listCount = snapshot.value as! Int
            self.ref.child("Tag").child("tags").child(tag).child("listCount").setValue(listCount - 1)
        }
        ref.child("Tag").child("tags").child(tag).child("listIDs").child(listID!).removeValue()
        // update the user's tagList
        ref.child("TagList").child(user.userID).child(tag).child(listID!).removeValue()
    }
}
