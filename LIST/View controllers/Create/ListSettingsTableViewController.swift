//
//  ListSettingsTableViewController.swift
//  LIST
//
//  Created by 蔡雨倩 on 10/06/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ListSettingsTableViewController: UITableViewController,  UITextFieldDelegate {
    
    let ref = Database.database().reference()
    let user = LISTUser()
    
    var listID: String?
    let picker = UIDatePicker()
    private var alert = UIAlertController(title: "Edit", message: "Edit the deadline:", preferredStyle: .alert)
    var newDdl: String?
    var dateStringForDatabase: String?
    var newRemainingDays: Int?
    var tags = [String]()
    var participantID = [String]()
    
    var settings = ["List name": "list name", "Creation date": "2018-07-01", "Deadline": "2018-12-31", "Priority level": "⭐️⭐️⭐️⭐️", "Who can view this list": "personal", "Tags": "Tap to see", "Collaborators": "Tap to see", "The most important list": "Click to set", "The most urgent list": "Click to set", "Delete this list": nil]
    private let priorityLevel = ["⭐️": 1, "⭐️⭐️": 2, "⭐️⭐️⭐️": 3, "⭐️⭐️⭐️⭐️": 4, "⭐️⭐️⭐️⭐️⭐️": 5]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // get all the participants
        ref.child("List").child(listID!).child("collaborator").observe(.value) { (snapshot) in
            self.participantID = [self.user.userID]
            if snapshot.exists() {
                if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                    for snap in snapshots {
                        self.participantID.append(snap.key)
                    }
                }
            }
        }
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings.count
    }

    /*
        If the list is newly created, use the default setting; otherwise fetch
        it from the databse
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row+1 < settings.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "listSettingsCell", for: indexPath)
            switch (indexPath.row){
            case 0:
                cell.accessoryType = .disclosureIndicator
                cell.textLabel?.text = "List name"
                cell.detailTextLabel?.text = settings["List name"]!
            case 1:
                cell.textLabel?.text = "Creation date"
                cell.detailTextLabel?.text = settings["Creation date"]!
            case 2:
                cell.accessoryType = .disclosureIndicator
                cell.textLabel?.text = "Deadline"
                cell.detailTextLabel?.text = settings["Deadline"]!
            case 3:
                cell.accessoryType = .disclosureIndicator
                cell.textLabel?.text = "Priority level"
                cell.detailTextLabel?.text = settings["Priority level"]!
            case 4:
                cell.accessoryType = .disclosureIndicator
                cell.textLabel?.text = "Who can view this list"
                cell.detailTextLabel?.text = settings["Who can view this list"]!
            case 5:
                cell.accessoryType = .disclosureIndicator
                cell.textLabel?.text = "Tags"
            case 6:
                cell.accessoryType = .disclosureIndicator
                cell.textLabel?.text = "Collaborators"
            case 7:
                cell.accessoryType = .disclosureIndicator
                cell.textLabel?.text = "The most important list"
                cell.detailTextLabel?.text = settings["The most important list"]!
            default:
                cell.accessoryType = .disclosureIndicator
                cell.textLabel?.text = "The most urgent list"
                cell.detailTextLabel?.text = settings["The most urgent list"]!
            }
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "listDeleteCell", for: indexPath)
            return cell
        }
    }

    // Handle different actions when a row is selected
    // todo: update the changes in the database, so that when tableview.reload()
    //       is called, the new value will be shown instead
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.row) {
        // MARK: change the list name
        case 0:
            let alert = UIAlertController(title: "Edit", message: "Edit your list name:", preferredStyle: .alert)
            var newName: String?
            alert.addTextField { (textField) in
                textField.placeholder = "Type the new name here"
            }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let edit = UIAlertAction(title: "OK", style: .default) { (_) in
                newName = alert.textFields?[0].text
                if newName != nil {
                    // change the list name in database
                    self.ref.child("List").child(self.listID!).child("listTitle").setValue(newName!)
                    print(newName!)
                    if let cell = tableView.cellForRow(at: indexPath) {
                        cell.detailTextLabel?.text = newName
                    }
                }
            }
            alert.addAction(cancel)
            alert.addAction(edit)
            present(alert, animated: true, completion: nil)
            tableView.reloadData()
        // MARK: change the deadline
        case 2:
            if alert.actions.count == 0 {
                alert.addTextField(configurationHandler: { [weak self](textField) in
                    self?.createDatePicker(textField)
                    textField.delegate = self
                })
                let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                let edit = UIAlertAction(title: "OK", style: .default) { (_) in
                    if let newDate = self.alert.textFields?[0].text, !newDate.isEmpty {
                        // change the deadline in database
                        self.updateDeadlineInDatabase(newDate: newDate)
                        if let cell = tableView.cellForRow(at: indexPath) {
                            cell.detailTextLabel?.text = newDate
                        }
                    }
                }
            alert.addAction(cancel)
            alert.addAction(edit)
            }
            present(alert, animated: true, completion: nil)
            tableView.reloadData()
        // MARK: change the priority level
        case 3:
            let previousLevel = settings["Priority level"] as! String
            let alert = UIAlertController(title: "Priority level", message: "Please choose the priority level", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "⭐️", style: .default, handler: { (action) in
                self.settings["Priority level"] = "⭐️"
                //update the priority level in the database
                self.ref.child("List").child(self.listID!).child("priority").setValue("⭐️")
                for person in self.participantID {
                    self.ref.child("PriorityList").child(person).child(previousLevel).child(self.listID!).removeValue()
                    self.ref.child("PriorityList").child(person).child("⭐️").child(self.listID!).setValue(self.listID!)
                }
                if let cell = tableView.cellForRow(at: indexPath) {
                    cell.detailTextLabel?.text = "⭐️"
                }
            }))
            alert.addAction(UIAlertAction(title: "⭐️⭐️", style: .default, handler: { (action) in
                self.settings["Priority level"] = "⭐️⭐️"
                //update the priority level in the database
                self.ref.child("List").child(self.listID!).child("priority").setValue("⭐️⭐️")
                for person in self.participantID {
                    self.ref.child("PriorityList").child(person).child(previousLevel).child(self.listID!).removeValue()
                    self.ref.child("PriorityList").child(person).child("⭐️⭐️").child(self.listID!).setValue(self.listID!)
                }
                if let cell = tableView.cellForRow(at: indexPath) {
                    cell.detailTextLabel?.text = "⭐️⭐️"
                }
            }))
            alert.addAction(UIAlertAction(title: "⭐️⭐️⭐️", style: .default, handler: { (action) in
                self.settings["Priority level"] = "⭐️⭐️⭐️"
                //update the priority level in the database
                self.ref.child("List").child(self.listID!).child("priority").setValue("⭐️⭐️⭐️")
                for person in self.participantID {
                    self.ref.child("PriorityList").child(person).child(previousLevel).child(self.listID!).removeValue()
                    self.ref.child("PriorityList").child(person).child("⭐️⭐️⭐️").child(self.listID!).setValue(self.listID!)
                }
                if let cell = tableView.cellForRow(at: indexPath) {
                    cell.detailTextLabel?.text = "⭐️⭐️⭐️"
                }
            }))
            alert.addAction(UIAlertAction(title: "⭐️⭐️⭐️⭐️", style: .default, handler: { (action) in
                self.settings["Priority level"] = "⭐️⭐️⭐️⭐️"
                //update the priority level in the database
                self.ref.child("List").child(self.listID!).child("priority").setValue("⭐️⭐️⭐️⭐️")
                for person in self.participantID {
                    self.ref.child("PriorityList").child(person).child(previousLevel).child(self.listID!).removeValue()
                    self.ref.child("PriorityList").child(person).child("⭐️⭐️⭐️⭐️").child(self.listID!).setValue(self.listID!)
                }
                if let cell = tableView.cellForRow(at: indexPath) {
                    cell.detailTextLabel?.text = "⭐️⭐️⭐️⭐️"
                }
            }))
            alert.addAction(UIAlertAction(title: "⭐️⭐️⭐️⭐️⭐️", style: .default, handler: { (action) in
                self.settings["Priority level"] = "⭐️⭐️⭐️⭐️⭐️"
                //update the priority level in the database
                self.ref.child("List").child(self.listID!).child("priority").setValue("⭐️⭐️⭐️⭐️⭐️")
                for person in self.participantID {
                    self.ref.child("PriorityList").child(person).child(previousLevel).child(self.listID!).removeValue()
                    self.ref.child("PriorityList").child(person).child("⭐️⭐️⭐️⭐️⭐️").child(self.listID!).setValue(self.listID!)
                }
                if let cell = tableView.cellForRow(at: indexPath) {
                    cell.detailTextLabel?.text = "⭐️⭐️⭐️⭐️⭐️"
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            tableView.reloadData()
        // MARK: change the privacy level
        case 4:
            let alert = UIAlertController(title: "Privacy level", message: "Who can view this list?", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "only me", style: .default, handler: { (action) in
                //update the privacy level in the database
                self.ref.child("List").child(self.listID!).child("privacy").setValue("only me")
                if let cell = tableView.cellForRow(at: indexPath) {
                    cell.detailTextLabel?.text = "only me"
                }
                self.ref.child("FriendList").child(self.user.userID).child(self.listID!).removeValue()
                // update inspiration pool if necessary
                self.updateInspirationPool()
            }))
            alert.addAction(UIAlertAction(title: "friends", style: .default, handler: { (action) in
                //update the privacy level in the database
                self.ref.child("List").child(self.listID!).child("privacy").setValue("friends")
                if let cell = tableView.cellForRow(at: indexPath) {
                    cell.detailTextLabel?.text = "friends"
                }
                // update FriendList
                self.ref.child("FriendList").child(self.user.userID).child(self.listID!).setValue(self.settings["List name"])
                // update inspiration pool if necessary
                self.updateInspirationPool()
            }))
            alert.addAction(UIAlertAction(title: "the public but I want to be anonymous", style: .default, handler: { (action) in
                //update the privacy level in the database
                self.ref.child("List").child(self.listID!).child("privacy").setValue("the public but I want to be anonomous")
                if let cell = tableView.cellForRow(at: indexPath) {
                    cell.detailTextLabel?.text = "the public but I want to be anonomous"
                }
                self.inputInspirationPool()
            }))
            alert.addAction(UIAlertAction(title: "the public", style: .default, handler: { (action) in
                //update the privacy level in the database
                self.ref.child("List").child(self.listID!).child("privacy").setValue("the public")
                if let cell = tableView.cellForRow(at: indexPath) {
                    cell.detailTextLabel?.text = "the public"
                }
                self.inputInspirationPool()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            tableView.reloadData()
        case 5:
            // perform segue
            self.performSegue(withIdentifier: "goToTagSettings", sender: self)
        case 6:
            // perform segue
            self.performSegue(withIdentifier: "goToCollaborators", sender: self)
        case 7:
            // set to be the most important list
            let alert = UIAlertController(title: "The most important list", message: "Are you sure to set this list as the most important list?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                // set
                self.ref.child("MostImportantList").child(self.user.userID).child("listID").observeSingleEvent(of: .value, with: { (snapshot) in
                    if snapshot.exists() {
                        let importantListID = snapshot.value as! String
                        if importantListID == self.listID! {
                            self.presentAlreadyListAlert(value: 0)
                        } else {
                            let listInfo = ["listID": self.listID!, "listTitle": self.settings["List name"] as! String]
                            self.ref.child("MostImportantList").child(self.user.userID).setValue(listInfo)
                            self.presentSetMostImportantListAlert()
                        }
                    } else {
                        let listInfo = ["listID": self.listID!, "listTitle": self.settings["List name"]]
                        self.ref.child("MostImportantList").child(self.user.userID).setValue(listInfo)
                        self.presentSetMostUrgentListAlert()
                    }
                })
            }))
            present(alert, animated: true, completion: nil)
        case 8:
            // set to be the most urgent list
            let alert = UIAlertController(title: "The most urgent list", message: "Are you sure to set this list as the most urgent list?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                // set
                self.ref.child("MostUrgentList").child(self.user.userID).child("listID").observeSingleEvent(of: .value, with: { (snapshot) in
                    if snapshot.exists() {
                        let urgentListID = snapshot.value as! String
                        if urgentListID == self.listID! {
                            self.presentAlreadyListAlert(value: 1)
                        } else {
                            let listInfo = ["listID": self.listID!, "listTitle": self.settings["List name"]]
                            self.ref.child("MostUrgentList").child(self.user.userID).setValue(listInfo)
                            self.presentSetMostUrgentListAlert()
                        }
                    } else {
                        let listInfo = ["listID": self.listID!, "listTitle": self.settings["List name"]]
                        self.ref.child("MostUrgentList").child(self.user.userID).setValue(listInfo)
                        self.presentSetMostUrgentListAlert()
                    }
                })
            }))
            present(alert, animated: true, completion: nil)
        case 9:
            let alert = UIAlertController(title: "Delete the list", message: "Are you sure to delete this list?", preferredStyle: .alert)
            let no = UIAlertAction(title: "Don't delete", style: .cancel, handler: nil)
            let yes = UIAlertAction(title: "Delete", style: .default) { (_) in
                // delete all the subgoals
                self.ref.child("ListItem").child(self.listID!).observeSingleEvent(of: .value, with: { (snapshot) in
                    if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                        for snap in snapshots {
                            let itemID = snap.key
                            self.ref.child("Subgoal").child(itemID).removeValue()
                        }
                    }
                })
                // delete all the items belonging to the list
                self.ref.child("ListItem").child(self.listID!).removeValue()
                
                // retrieve tags first, then delete from TagList
                self.ref.child("List").child(self.listID!).child("tag").queryOrdered(byChild: "tagName").observeSingleEvent(of: .value, with: { (snapshot) in
                    if snapshot.exists() {
                        if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                            for snap in snapshots {
                                for person in self.participantID {
                                    self.ref.child("TagList").child(person).child(snap.key).child(self.listID!).removeValue()
                                }
                                self.ref.child("Tag").child(snap.key).child("listCount").observeSingleEvent(of: .value, with: { (snapshot) in
                                    let count = snapshot.value as! Int
                                    self.ref.child("Tag").child(snap.key).child("listCount").setValue(count - 1)
                                })
                                self.ref.child("Tag").child(snap.key).child("listIDs").child(self.listID!).removeValue()
                            }
                        }
                    }
                })
                
                // including deadlineList and priorityList of all participants
                self.ref.child("List").child(self.listID!).child("remainingDays").observeSingleEvent(of: .value, with: { (snapshot) in
                    let remainingDays = snapshot.value as! Int
                    for person in self.participantID {
                        self.ref.child("DeadlineList").child(person).child("\(remainingDays)").child(self.listID!).removeValue()
                        self.ref.child("PriorityList").child(person).child(self.settings["Priority level"] as! String).child(self.listID!).removeValue()
                    }
                    // delete the list in database
                    self.ref.child("List").child(self.listID!).removeValue()
                })

                self.performSegue(withIdentifier: "afterDeleteList", sender: self)
            }
            alert.addAction(no)
            alert.addAction(yes)
            present(alert, animated: true, completion: nil)
            tableView.reloadData()
        default:
            break
        }
    }
    
    func presentSetMostImportantListAlert() {
        let alert = UIAlertController(title: "Successful", message: "Set the most important list successfully", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func presentSetMostUrgentListAlert() {
        let alert = UIAlertController(title: "Successful", message: "Set the most urgent list successfully", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func presentAlreadyListAlert(value: Int) {
        var listType = String()
        if value == 0 {
            listType = "important"
        } else {
            listType = "urgent"
        }
        let alert = UIAlertController(title: "Note", message: "This list has already been set as the most \(listType) list.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: Set the date picker with a tool bar
    func createDatePicker(_ textField: UITextField){
        print("createDatePicker is called")
        // toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        // done button for toolbar
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed))
        toolbar.setItems([done], animated: false)
        
        textField.inputAccessoryView = toolbar
        textField.inputView = picker
        
        // format picker for date
        picker.datePickerMode = .date
        textField.text = newDdl
    }
    
    @objc func donePressed() {
        print("donePressed is called")
        // format date
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        let formatterForDatabase = DateFormatter()
        formatterForDatabase.dateFormat = "dd-MM-yyyy"
        dateStringForDatabase = formatterForDatabase.string(from: picker.date)
        let dateString = formatter.string(from: picker.date)
        print("newDdl = \(dateString)")
        newDdl = "\(dateString)"
        newRemainingDays = calculateDaysLeft(deadlineDate: picker.date)
        print(newDdl!)
        alert.textFields?[0].text = newDdl
        self.view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToTagSettings"{
            if let destination = segue.destination as? TagsTableViewController {
                destination.listID = listID
                destination.participantID = participantID
                // retrieve tags of the list in database
                ref.child("List").child(listID!).child("tag").queryOrdered(byChild: "tagName").observe(.value, with: { (snapshot) in
                    destination.cellTitle.removeAll()
                    destination.cellTitle.append("Add more tags")
                    if snapshot.exists() {
                        if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                            for snap in snapshots {
                                destination.cellTitle.insert(snap.value as! String, at: 0)
                            }
                        }
                    }
                    destination.tableView.reloadData()
                })
            }
        } else if segue.identifier == "goToCollaborators"{
            if let destination = segue.destination as? CollaboratorTableViewController {
                destination.listID = listID!
                ref.child("List").child(listID!).child("collaborator").observe(.value, with: { (snapshot) in
                    destination.collaborators.removeAll()
                    if snapshot.exists() {
                        if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                            for snap in snapshots {
                                destination.collaborators.append(snap.key)
                            }
                        }
                    }
                    destination.tableView.reloadData()
                })
            }
        }
    }
    
    func calculateDaysLeft(deadlineDate: Date) -> Int {
        print("calculating days left...")
        var daysLeft = 0
        let todayInterval = Int(Date().timeIntervalSinceReferenceDate/(3600 * 24))
        let deadlineInterval = Int(deadlineDate.timeIntervalSinceReferenceDate/(3600 * 24))
        
        daysLeft = deadlineInterval - todayInterval
        
        return daysLeft < 0 ? 0 : daysLeft
    }
    
    func updateDeadlineInDatabase(newDate: String) {
       // update DdlList first
        var oldRemainingDays = 0
        let deadlineUpdate = ["listTitle": settings["List name"], "deadline": newDdl!]
        self.ref.child("List").child(self.listID!).child("remainingDays").observeSingleEvent(of: .value, with: {(snapshot) in
            oldRemainingDays = snapshot.value as! Int
            print("oldRemaingDays is = \(oldRemainingDays)")
            for person in self.participantID {
                self.ref.child("DeadlineList").child(person).child("\(oldRemainingDays)").child(self.listID!).removeValue()
                self.ref.child("DeadlineList").child(person).child("\(self.newRemainingDays!)").child(self.listID!).setValue(deadlineUpdate)
            }
            self.ref.child("List").child(self.listID!).child("remainingDays").setValue(self.newRemainingDays!)
            self.ref.child("List").child(self.listID!).child("deadline").setValue(newDate)
        })
    }
    
    func updateInspirationPool() {
        ref.child("ListItem").child(self.listID!).observeSingleEvent(of: .value) { (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshots {
                    let itemID = snap.key
                    self.ref.child("InspirationPool").child(itemID).removeValue()
                }
            }
        }
    }
    
    func inputInspirationPool() {
        ref.child("List").child(listID!).child("tag").observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                self.ref.child("ListItem").child(self.listID!).observeSingleEvent(of: .value) { (snapshot) in
                    if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                        for snap in snapshots {
                            let itemID = snap.key
                            self.ref.child("InspirationPool").child(itemID).observeSingleEvent(of: .value, with: { (snapshot) in
                                if !snapshot.exists() {
                                    let itemInfo = snap.value as! [String: Any]
                                    let addInfo = ["content": itemInfo["content"] as! String, "listID": self.listID!]
                                    self.ref.child("InspirationPool").child(itemID).setValue(addInfo)
                                }
                            })
                        }
                    }
                }
            }
        }
    }
}

