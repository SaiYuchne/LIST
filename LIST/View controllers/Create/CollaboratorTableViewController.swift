//
//  CollaboratorTableViewController.swift
//  LIST
//
//  Created by 蔡雨倩 on 21/06/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import UIKit
import FirebaseDatabase

class CollaboratorTableViewController: UITableViewController {

    let ref = Database.database().reference()
    var collaborators = [String]() // IDs
    let user = LISTUser()
    var listID: String?
    
    var newCollaboratorEmail = String()
    var invitationUpdate: Int = 0 {
        didSet {
            print("invitationUpdate has been set")
            let path = newCollaboratorEmail.removeCharacters(from: ".")
            ref.child("UserID").child(path).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    let collaboratorID = snapshot.value as! String
                    if(self.isNewCollaborator(collaboratorID)){
                        self.ref.child("CollaborationInvitation").child(collaboratorID).child(self.listID!).setValue(self.user.userID)
                        
                        self.ref.child("List").child(self.listID!).child("collaborator").child(collaboratorID).setValue(collaboratorID)
                        
                        self.updateAccessInDatabase(receiverID: collaboratorID)
                        self.presentInvitationHasBeenSentAlert()
                    } else {
                        if(collaboratorID == self.user.userID) {
                            self.presentAddSelfAlert()
                        }
                        self.presentOldCollaboratorAlert()
                    }
                } else {
                    self.presentNonUserAlert()
                }
            })
        }
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return collaborators.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0_{
            let cell = tableView.dequeueReusableCell(withIdentifier: "addCollaboratorCell")
            return cell!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell") as! FriendTableViewCell
            cell.cellView.layer.cornerRadius = cell.cellView.frame.height / 2
            ref.child("Profile").child(collaborators[indexPath.row]).observeSingleEvent(of: .value, with: { (snapshot) in
                if let collaboratorInfo = snapshot.value as? [String: Any] {
                    cell.userNameLabel.text = collaboratorInfo["userName"] as! String
                    cell.mottoLabel.text = collaboratorInfo["motto"] as? String
                    cell.iconPic.image = UIImage(named: "icon")
                    cell.iconPic.layer.cornerRadius = cell.iconPic.frame.height / 2
                    cell.iconPic.clipsToBounds = true
                }
            })
            return cell
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
                let alert = UIAlertController(title: "Warning", message: "Delete this collaborator?", preferredStyle: .alert)
                let no = UIAlertAction(title: "No", style: .cancel, handler: nil)
                let yes = UIAlertAction(title: "Yes", style: .default) { (_) in
                    // delete data in the database
                    self.deleteCollaboratorFromDatabase(collaboratorID: self.collaborators[indexPath.row])
                    self.collaborators.remove(at: indexPath.row)
                }
                alert.addAction(no)
                alert.addAction(yes)
                present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func addCollaboratorTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Add a new collaborator", message: "Type the collaborator's email:", preferredStyle: .alert)
        var email: String?
        alert.addTextField { (textField) in
            textField.placeholder = "Type the email here"
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let ok = UIAlertAction(title: "Ok", style: .default) { (_) in
            email = alert.textFields?[0].text
            if email != nil {
                self.newCollaboratorEmail = email!
                self.invitationUpdate = 1
            } else {
                let alert = UIAlertController(title: "Error", message: "Email cannot be blank.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        alert.addAction(cancel)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    func presentOldCollaboratorAlert() {
        let alert = UIAlertController(title: "Sorry", message: "The user is already a collaborator of this list.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func presentNonUserAlert() {
        let alert = UIAlertController(title: "Sorry", message: "The user does not exist.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func presentAddSelfAlert() {
        let alert = UIAlertController(title: "Sorry", message: "You are already the creator of this list.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func presentInvitationHasBeenSentAlert() {
        let alert = UIAlertController(title: "Successful", message: "The user has become a new collaborator of this list", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: database operations
    func deleteCollaboratorFromDatabase(collaboratorID: String) {
            ref.child("List").child(listID!).child("collaborator").child(collaboratorID).removeValue()
            
            // delete the collaborator's access to this list
            
            ref.child("List").child(listID!).child("priority").observeSingleEvent(of: .value) { (snapshot) in
                let priorityLevel = snapshot.value as! String
                var tags = [String]()
                self.ref.child("List").child(self.listID!).child("tag").observeSingleEvent(of: .value) { (snapshot) in
                    tags.removeAll()
                    if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                        for snap in snapshots {
                            tags.append(snap.value as! String)
                        }
                    }
                }
                
                // PriorityList
                self.ref.child("PriorityList").child(collaboratorID).child(priorityLevel).child(self.listID!).removeValue()
                // DeadlineList
                self.ref.child("DeadlineList").child(collaboratorID).child(self.listID!).removeValue()
                //TagList
                for tag in tags {
                    self.ref.child("TagList").child(collaboratorID).child(tag).child(self.listID!).removeValue()
                }
            }
            
        
    }
    
    func updateAccessInDatabase(receiverID: String) {
        
        ref.child("List").child(listID!).observeSingleEvent(of: .value) { (snapshot) in
            var tags = [String]()
                if let listInfo = snapshot.value as? [String: Any] {
                let priorityLevel = listInfo["priority"] as! String
                let deadline = listInfo["deadline"] as! String
                let listTitle = listInfo["listTitle"] as! String
                print("priorityLevel = \(priorityLevel)")
                    print("deadline = \(deadline)")
                    print("listTitle = \(listTitle)")
                    
                    self.ref.child("List").child(self.listID!).child("tag").observeSingleEvent(of: .value) { (snapshot) in
                        tags.removeAll()
                        if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                            for snap in snapshots {
                                tags.append(snap.value as! String)
                            }
                        }
                    }
                    
                    // PriorityList
                    self.ref.child("PriorityList").child(receiverID).child(priorityLevel).child(self.listID!).setValue(self.listID!)
                    // DeadlineList
                    let deadlineListInfo = ["listTitle": listTitle, "deadline": deadline]
                    self.ref.child("DeadlineList").child(receiverID).child(self.listID!).setValue(deadlineListInfo)
                    //TagList
                    for tag in tags {
                        self.ref.child("TagList").child(receiverID).child(tag).child(self.listID!).setValue(listTitle)
                    }
            }
        }
        
    }
    
    func isNewCollaborator(_ collaboratorID: String) -> Bool{
        var doesExist = false
        ref.child("List").child(listID!).child("collaborator").child(collaboratorID).observe(.value) { (snapshot) in
            if snapshot.exists() {
                doesExist = true
            }
        }
        return !doesExist
    }
}
