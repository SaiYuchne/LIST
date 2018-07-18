//
//  MessageTableViewController.swift
//  LIST
//
//  Created by 蔡雨倩 on 23/06/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import UIKit
import FirebaseDatabase

class MessageTableViewController: UITableViewController {

    let ref = Database.database().reference()
    var invitationListIDs = [String]()
    var senderIDs = [String]()
    let user = LISTUser()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getDataFromDatabase()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return invitationListIDs.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "invitationCell", for: indexPath) as! InvitationTableViewCell
        // Configure the cell
        cell.senderID = senderIDs[indexPath.row]
        cell.listID = invitationListIDs[indexPath.row]
        let senderName = ref.child("Profile").child(cell.senderID!).value(forKey: "username") as! String
        cell.label.text = "\(senderName) sends you an invitation"
        return cell
    }
   

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! InvitationTableViewCell
        let senderName = ref.child("Profile").child(cell.senderID!).value(forKey: "username") as! String
        let listName = ref.child("List").child(cell.listID!).value(forKey: "listTitle") as! String
        
        let alert = UIAlertController(title: "Invitation", message: "\(senderName) has invited you to complete \"\(listName)\". Now you can access the list.", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    // Database operations
    func getDataFromDatabase() {
        let invitationRef = ref.child("CollaborationInvitation")
        invitationRef.observeSingleEvent(of: .value) { (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshots {
                    self.invitationListIDs.append(snap.key)
                    self.senderIDs.append(snap.value as! String)
                }
            }
        }
    }
}
