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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getTableViewDataFromDatabase()
    }

   
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requestID.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendRequestTableViewCell") as! FriendRequestTableViewCell
        ref.child("User").child(requestID[indexPath.row]).observeSingleEvent(of: .value) { (snapshot) in
            if let friendInfo = snapshot.value as? Dictionary<String, Any> {
                cell.usernameLabel.text = friendInfo["username"] as? String
                // iconPic
            }
        }
            self.ref.child("FriendRequest").child(userID!).child(requestID[indexPath.row]).observeSingleEvent(of: .value) { (snapshot) in
                if let friendInfo = snapshot.value as? String {
                    cell.infoLabel.text = friendInfo
                }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "Add new friend", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            let friendID = self.requestID[indexPath.row]
            self.ref.child("Friend").child(self.userID!).child(friendID).setValue(friendID)
            self.ref.child("Friend").child(friendID).child(self.userID!).setValue(friendID)
            self.ref.child("FriendRequest").child(self.userID!).child(friendID).removeValue()
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    // MARK: database operations
    func getTableViewDataFromDatabase() {
        let requestRef = ref.child("Friend").child(userID!)
        requestRef.observeSingleEvent(of: .value) { (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshots {
                    self.requestID.append(snap.value as! String)
                }
            }
        }
    }
    
}
