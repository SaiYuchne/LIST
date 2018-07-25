//
//  FriendRequestTableViewController.swift
//  LIST
//
//  Created by 蔡雨倩 on 19/06/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import UIKit
import FirebaseDatabase

class FriendRequestTableViewController: UITableViewController {

    let ref = Database.database().reference()
    var userID: String?
    var requestID = [String]()
    var messages = [String]()

   
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requestID.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendRequestTableViewCell") as! FriendRequestTableViewCell
        ref.child("Profile").child(requestID[indexPath.row]).observeSingleEvent(of: .value) { (snapshot) in
            if let friendInfo = snapshot.value as? [String: Any] {
                cell.usernameLabel.text = friendInfo["userName"] as! String
                cell.infoLabel.text = self.messages[indexPath.row]
                // MARK: TODO: iconPic
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "Add new friend", message: "Would you like to accept the request?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            let friendID = self.requestID[indexPath.row]
            self.ref.child("Friend").child(self.userID!).child(friendID).setValue(friendID)
            self.ref.child("Friend").child(friendID).child(self.userID!).setValue(self.userID!)
            self.ref.child("FriendRequest").child(self.userID!).child(friendID).removeValue()
            self.messages.remove(at: indexPath.row)
            self.requestID.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: {(action) in
            let friendID = self.requestID[indexPath.row]
            self.ref.child("FriendRequest").child(self.userID!).child(friendID).removeValue()
            self.messages.remove(at: indexPath.row)
            self.requestID.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
