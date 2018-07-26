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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let invitationRef = ref.child("CollaborationInvitation").child(user.userID)
        invitationRef.observe(.value) { (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                self.invitationListIDs.removeAll()
                self.senderIDs.removeAll()
                for snap in snapshots {
                    self.invitationListIDs.append(snap.key)
                    self.senderIDs.append(snap.value as! String)
                }
            }
            self.tableView.reloadData()
        }
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
        ref.child("Profile").child(cell.senderID!).child("userName").observeSingleEvent(of: .value) { (snapshot) in
            let senderName = snapshot.value as! String
            cell.label.text = "\(senderName) sends you an invitation"
        }
        return cell
    }
   
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! InvitationTableViewCell
        ref.child("List").child(cell.listID!).child("listTitle").observeSingleEvent(of: .value) { (snapshot) in
            let listName = snapshot.value as! String
            self.ref.child("Profile").child(cell.senderID!).child("userName").observeSingleEvent(of: .value, with: { (snapshot) in
                let senderName = snapshot.value as! String
                
                let alert = UIAlertController(title: "Invitation", message: "\(senderName) has invited you to complete \"\(listName)\". Now you can access the list.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            })
        }
        self.deleteInvitationInDatabase(listID: invitationListIDs[indexPath.row])
        self.senderIDs.remove(at: indexPath.row)
        self.invitationListIDs.remove(at: indexPath.row)
        self.tableView.deleteRows(at: [indexPath], with: .fade)
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
    func deleteInvitationInDatabase(listID: String) {
        ref.child("CollaborationInvitation").child(user.userID).child(listID).removeValue()
    }
}
