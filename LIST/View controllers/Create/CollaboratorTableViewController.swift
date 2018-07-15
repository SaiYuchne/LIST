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
    var collaborators = [String]()
    let user = LISTUser()
    var listID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        if indexPath.section == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "addCollaboratorCell")
            return cell!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell") as! FriendTableViewCell
            cell.cellView.layer.cornerRadius = cell.cellView.frame.height / 2
            ref.child("User").child(collaborators[indexPath.row]).observeSingleEvent(of: .value, with: { (snapshot) in
                if let collaboratorInfo = snapshot.value as? Dictionary<String, Any> {
                    cell.userNameLabel.text = collaboratorInfo["username"] as? String
                    cell.mottoLabel.text = collaboratorInfo["motto"] as? String
                }
            })
            return cell
        }
    }
    
    // MARK: delete list items
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            if indexPath.row == 0 {
                let alert = UIAlertController(title: "Warning", message: "Delete this collaborator?", preferredStyle: .alert)
                let no = UIAlertAction(title: "No", style: .cancel, handler: nil)
                let yes = UIAlertAction(title: "Yes", style: .default) { (_) in
                    // delete data in the database
                    self.deleteCollaboratorFromDatabase(email: self.collaborators[indexPath.row])
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
                var doesExist = false
                self.ref.child("UserID").child(email!).observeSingleEvent(of: .value, with: { (snapshot) in
                    if snapshot.value != nil {
                        doesExist = true
                    }
                })
                if(doesExist) {
                    self.updateAccessInDatabase(email: email!)
                    self.addInvitationMessageInDatabase(email: email!)
                } else {
                    let alert = UIAlertController(title: "Sorry", message: "The user you try to find does not exist.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
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
    
    // MARK: database operations
    func deleteCollaboratorFromDatabase(email: String) {
        var newCollaborators = [String]()
        let collaboratorID = ref.child("UserID").value(forKey: email) as! String
        ref.child("List").child(listID!).child("collaborator").observeSingleEvent(of: .value) { (snapshot) in
            if let tempData = snapshot.value as? [String] {
                newCollaborators = tempData
            }
            
            newCollaborators.remove(at: newCollaborators.index(of: collaboratorID)!)
            self.ref.child("List").child(self.listID!).child("collaborator").setValue(newCollaborators)
        }
        // delete the collaborator's access to this list
        // priority list
        let priorityLevel = ref.child("List").child(listID!).value(forKey: "priority") as! String
        ref.child("PriorityList").child(collaboratorID).child(priorityLevel).observeSingleEvent(of: .value) { (snapshot) in
            if var lists = snapshot.value as? [String] {
                lists.remove(at: lists.index(of: self.listID!)!)
                self.ref.child("PriorityList").child(collaboratorID).child(priorityLevel).setValue(lists)
            }
        }
        // deadline list
        ref.child("DeadlineList").child(collaboratorID).child(listID!).removeValue()
        // tag list
        ref.child("TagList").child(collaboratorID).child(listID!).removeValue()
    }
    
    func updateAccessInDatabase(email: String) {
        let receiverID = ref.child("UserID").value(forKey: email) as! String
        let priorityLevel = ref.child("List").child(listID!).value(forKey: "priority") as! String
        let deadline = ref.child("List").child(listID!).value(forKey: "deadline") as! String
        let listTitle = ref.child("List").child(listID!).value(forKey: "listTitle") as! String
        let tags = ref.child("List").child(listID!).value(forKey: "tag") as! [String]
        // PriorityList
        var priorityLists = ref.child("PriorityList").child(receiverID).value(forKey: priorityLevel) as! [String]
        priorityLists.append(listID!)
        ref.child("PriorityList").child(receiverID).child(priorityLevel).setValue(priorityLists)
        // DeadlineList
        let listInfo1 = ["listTitle": listTitle, "deadline": deadline]
        ref.child("DeadlineList").child(receiverID).child(listID!).setValue(listInfo1)
        //TagList
        let listInfo2 = ["listTitle": listTitle, "tag": tags] as [String : Any]
        ref.child("TagList").child(receiverID).child(listID!).setValue(listInfo2)
    }
    
    func addInvitationMessageInDatabase(email: String) {
        let receiverID = ref.child("UserID").value(forKey: email) as! String
        ref.child("CollaborationInvitation").child(receiverID).child(listID!).setValue(user.userID)
    }
}
