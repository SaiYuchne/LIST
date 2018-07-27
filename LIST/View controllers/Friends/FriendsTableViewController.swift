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
    var friendIDs = [String]()
    var chosenRow = Int()
    let user = LISTUser()
    
    var hasFriendRequest = false {
        didSet {
            self.tableView.reloadData()
        }
    }
    var newFriendEmail = String()
    var message = String()
    var requestUpdate: Int = 0 {
        didSet {
            print("requestUpdate has been set")
            let path = newFriendEmail.removeCharacters(from: ".")
            print("mark 1: path = \(path)")
            
            ref.child("UserID").child(path).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    print("snapshot exists")
                    let friendID = snapshot.value as! String
                    print("mark 2: friendID = \(friendID)")
                    let content = [self.user.userID: self.message]
                    if(self.isNewFriend(friendID)){
                    self.ref.child("FriendRequest").child(friendID).setValue(content)
                        self.presentRequestHasBeenSentAlert()
                    } else {
                        if(friendID == self.user.userID) {
                            self.presentAddSelfAlert()
                        }
                        self.presentOldFriendAlert()
                    }
                } else {
                    self.presentNonUserAlert()
                }
            })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getTableViewDataFromDatabase()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return friendIDs.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "friendNotificationCell") as! FriendNotificationTableViewCell
            if hasFriendRequest {
                cell.newRequestButton.titleLabel?.text = "🔉New request!"
            } else {
                cell.newRequestButton.titleLabel?.text = "🔇No request"
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell") as! FriendTableViewCell
            cell.cellView.layer.cornerRadius = cell.cellView.frame.height / 2
            ref.child("Profile").child(friendIDs[indexPath.row]).observeSingleEvent(of: .value, with: { (snapshot) in
                if let friendInfo = snapshot.value as? [String: Any] {
                    cell.userNameLabel.text = friendInfo["userName"] as! String
                    cell.mottoLabel.text = friendInfo["motto"] as! String
                    cell.iconPic.image = UIImage(named: "icon")
                    cell.iconPic.layer.cornerRadius = cell.iconPic.frame.height / 2
                    cell.iconPic.clipsToBounds = true
                }
            })
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            chosenRow = indexPath.row
            performSegue(withIdentifier: "goToFriendListMenu", sender: self)
        }
    }
    
    // MARK: delete list items
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section != 0 {
            return true
        }
        return false
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            if indexPath.section != 0 {
                let alert = UIAlertController(title: "Warning", message: "Delete this friend? You will be deleted from this user's friend list as well.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                    self.deleteFriendInDatabase(friendID: self.friendIDs[indexPath.row])
                    self.friendIDs.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                present(alert, animated: true, completion: nil)
            }
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
                print("email = \(email!)")
                self.newFriendEmail = email!
                let alert2 = UIAlertController(title: "Leave a message", message: "Leave a message to the new friend", preferredStyle: .alert)
                alert2.addTextField { (textField) in
                    textField.placeholder = "Type the massage here"
                }
                let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                let ok = UIAlertAction(title: "Ok", style: .default) { (_) in
                    if let tempWord = alert2.textFields?[0].text {
                        self.message = tempWord
                        print("message = \(self.message)")
                        self.requestUpdate = 1
                    }
                }
                alert2.addAction(cancel)
                alert2.addAction(ok)
                self.present(alert2, animated: true, completion: nil)
            }
        }
        alert.addAction(cancel)
        alert.addAction(next)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func newRequestButtonTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: "goToFriendRequest", sender: self)
    }
    
    func presentOldFriendAlert() {
        let alert = UIAlertController(title: "Sorry", message: "You two have already been friends.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func presentNonUserAlert() {
        let alert = UIAlertController(title: "Sorry", message: "The user does not exist.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func presentAddSelfAlert() {
        let alert = UIAlertController(title: "Sorry", message: "You cannot add yourself as a friend.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func presentRequestHasBeenSentAlert() {
        let alert = UIAlertController(title: "Successful", message: "Your request has been sent to that user.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToFriendRequest" {
            if let destination = segue.destination as? FriendRequestTableViewController {
                destination.userID = user.userID
                ref.child("FriendRequest").child(user.userID).observe(.value, with: { (snapshot) in
                    destination.requestID.removeAll()
                    destination.messages.removeAll()
                    if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                        for snap in snapshots {
                            destination.requestID.append(snap.key)
                            destination.messages.append(snap.value as! String)
                        }
                    }
                    destination.tableView.reloadData()
                })
            }
        } else if segue.identifier == "goToFriendListMenu" {
            if let destination = segue.destination as?
                FriendListViewController {
                ref.child("FriendList").child(friendIDs[chosenRow]).observeSingleEvent(of: .value, with: { (snapshot) in
                    if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                        destination.listTitles.removeAll()
                        destination.listIDs.removeAll()
                        for snap in snapshots {
                            destination.listIDs.append(snap.key)
                            destination.listTitles.append(snap.value as! String)
                        }
                    }
                    destination.tableView.reloadData()
                })
            }
        }
    }
    
    // MARK: database operations
    func getTableViewDataFromDatabase() {
        print("accessing friend info in database...")
        let friendRef = ref.child("Friend").child(user.userID)
        friendRef.observe(.value) { (snapshot) in
            self.friendIDs.removeAll()
            if snapshot.exists() {
                print("the user has friends")
                if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                    for snap in snapshots {
                        self.friendIDs.append(snap.value as! String)
                    }
                }
            }
            self.ref.child("FriendRequest").child(self.user.userID).observe(.value) { (snapshot) in
                self.hasFriendRequest = false
                if snapshot.exists() {
                    self.hasFriendRequest = true
                    print("self.hasFriendRequest = true")
                }
            }
            self.tableView.reloadData()
        }
    }
    
    func isNewFriend(_ friendID: String) -> Bool{
       var doesExist = false
        ref.child("Friend").child(user.userID).child(friendID).observe(.value) { (snapshot) in
            if snapshot.exists() {
                doesExist = true
            }
        }
        return !doesExist
    }
    
    func deleteFriendInDatabase(friendID: String) {
        ref.child("Friend").child(user.userID).child(friendID).removeValue()
        ref.child("Friend").child(friendID).child(user.userID).removeValue()
    }
}
