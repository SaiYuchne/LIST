//
//  FriendsTableViewController.swift
//  LIST
//
//  Created by 蔡雨倩 on 19/06/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import UIKit
import FirebaseDatabase

class FriendsTableViewController: UITableViewController {

    let ref = Database.database().reference()
    var friends = [String]()
    let user = LISTUser()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getTableViewDataFromDatabase()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if hasFriendRequest() {
                return 1
            } else {
                return 0
            }
        } else {
            return friends.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0, tableView.numberOfRows(inSection: 0) != 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "friendNotificationCell") as! FriendNotificationTableViewCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell") as! FriendTableViewCell
            cell.cellView.layer.cornerRadius = cell.cellView.frame.height / 2
            ref.child("User").child(friends[indexPath.row]).observeSingleEvent(of: .value, with: { (snapshot) in
                if let friendInfo = snapshot.value as? Dictionary<String, Any> {
                    cell.userNameLabel.text = friendInfo["username"] as? String
                    cell.mottoLabel.text = friendInfo["motto"] as? String
                }
            })
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            
        }
    }
    
    @IBAction func addFriendButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Add new friend", message: "Type your friend's email:", preferredStyle: .alert)
        var email: String?
        alert.addTextField { (textField) in
            textField.placeholder = "Type the email here"
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let next = UIAlertAction(title: "Next", style: .default) { (_) in
            email = alert.textFields?[0].text
            if email != nil {
                let alert = UIAlertController(title: "Leave a message", message: "Leave a message to the new friend", preferredStyle: .alert)
                var message: String?
                alert.addTextField { (textField) in
                    textField.placeholder = "Type the massage here"
                }
                let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                let ok = UIAlertAction(title: "Ok", style: .default) { (_) in
                    message = alert.textFields?[0].text
                    let friendID = self.ref.child("UserID").value(forKey: email!) as! String
                    let content = [self.user.userID: message]
                    self.ref.child("FriendRequest").child(friendID).setValue(content)
                }
                alert.addAction(cancel)
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
            }
        }
        alert.addAction(cancel)
        alert.addAction(next)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func newRequestButtonTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: "goToFriendRequest", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToFriendRequest" {
            if let destination = segue.destination as? FriendRequestTableViewController {
                destination.userID = user.userID
            }
        }
    }
    
    // MARK: database operations
    func getTableViewDataFromDatabase() {
        let friendRef = ref.child("Friend").child(user.userID)
        friendRef.observeSingleEvent(of: .value) { (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshots {
                    self.friends.append(snap.value as! String)
                }
            }
        }
    }
    
    func hasFriendRequest() -> Bool {
        var hasNewRequest = false
        let requestRef = ref.child("FriendRequest").child(user.userID)
        requestRef.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.value != nil {
                    hasNewRequest = true
            }
        }
        return hasNewRequest
    }
}
