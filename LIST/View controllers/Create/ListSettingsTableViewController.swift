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
    
    var settings = ["List name": "list name", "Creation date": "2018-07-01", "Deadline": "2018-12-31", "Priority level": "⭐️⭐️⭐️⭐️", "Who can view this list": "personal", "Tags": nil, "Collaborators": nil, "Delete this list": nil]
    private let priorityLevel = ["⭐️": 1, "⭐️⭐️": 2, "⭐️⭐️⭐️": 3, "⭐️⭐️⭐️⭐️": 4, "⭐️⭐️⭐️⭐️⭐️": 5]
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
            default:
                cell.accessoryType = .disclosureIndicator
                cell.textLabel?.text = "Collaborators"
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
                    self.alert.textFields?[0].text = self.newDdl
                    if let newDate = self.alert.textFields?[0].text {
                        // change the deadline in database
                        self.ref.child("List").child(self.listID!).child("deadline").setValue(newDate)
                        print("the new date is \(newDate)")
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
                self.ref.child("PriorityList").child(self.user.userID).child(previousLevel).child(self.listID!).removeValue()
                self.ref.child("PriorityList").child(self.user.userID).child("⭐️").child(self.listID!).setValue(self.listID!)
                if let cell = tableView.cellForRow(at: indexPath) {
                    cell.detailTextLabel?.text = "⭐️"
                }
            }))
            alert.addAction(UIAlertAction(title: "⭐️⭐️", style: .default, handler: { (action) in
                self.settings["Priority level"] = "⭐️⭐️"
                //update the priority level in the database
                self.ref.child("List").child(self.listID!).child("priority").setValue("⭐️⭐️")
                self.ref.child("PriorityList").child(self.user.userID).child(previousLevel).child(self.listID!).removeValue()
                self.ref.child("PriorityList").child(self.user.userID).child("⭐️⭐️").child(self.listID!).setValue(self.listID!)
                if let cell = tableView.cellForRow(at: indexPath) {
                    cell.detailTextLabel?.text = "⭐️⭐️"
                }
            }))
            alert.addAction(UIAlertAction(title: "⭐️⭐️⭐️", style: .default, handler: { (action) in
                self.settings["Priority level"] = "⭐️⭐️⭐️"
                //update the priority level in the database
                self.ref.child("List").child(self.listID!).child("priority").setValue("⭐️⭐️⭐️")
                self.ref.child("PriorityList").child(self.user.userID).child(previousLevel).child(self.listID!).removeValue()
                self.ref.child("PriorityList").child(self.user.userID).child("⭐️⭐️⭐️").child(self.listID!).setValue(self.listID!)
                if let cell = tableView.cellForRow(at: indexPath) {
                    cell.detailTextLabel?.text = "⭐️⭐️⭐️"
                }
            }))
            alert.addAction(UIAlertAction(title: "⭐️⭐️⭐️⭐️", style: .default, handler: { (action) in
                self.settings["Priority level"] = "⭐️⭐️⭐️⭐️"
                //update the priority level in the database
                self.ref.child("List").child(self.listID!).child("priority").setValue("⭐️⭐️⭐️⭐️")
                self.ref.child("PriorityList").child(self.user.userID).child(previousLevel).child(self.listID!).removeValue()
                self.ref.child("PriorityList").child(self.user.userID).child("⭐️⭐️⭐️⭐️").child(self.listID!).setValue(self.listID!)
                if let cell = tableView.cellForRow(at: indexPath) {
                    cell.detailTextLabel?.text = "⭐️⭐️⭐️⭐️"
                }
            }))
            alert.addAction(UIAlertAction(title: "⭐️⭐️⭐️⭐️⭐️", style: .default, handler: { (action) in
                self.settings["Priority level"] = "⭐️⭐️⭐️⭐️⭐️"
                //update the priority level in the database
                self.ref.child("List").child(self.listID!).child("priority").setValue("⭐️⭐️⭐️⭐️⭐️")
                self.ref.child("PriorityList").child(self.user.userID).child(previousLevel).child(self.listID!).removeValue()
                self.ref.child("PriorityList").child(self.user.userID).child("⭐️⭐️⭐️⭐️⭐️").child(self.listID!).setValue(self.listID!)
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
                //update the priority level in the database
                self.ref.child("List").child(self.listID!).child("privacy").setValue("only me")
                if let cell = tableView.cellForRow(at: indexPath) {
                    cell.detailTextLabel?.text = "only me"
                }
            }))
            alert.addAction(UIAlertAction(title: "friends", style: .default, handler: { (action) in
                //update the priority level in the database
                self.ref.child("List").child(self.listID!).child("privacy").setValue("friends")
                if let cell = tableView.cellForRow(at: indexPath) {
                    cell.detailTextLabel?.text = "friends"
                }
            }))
            alert.addAction(UIAlertAction(title: "the public but I want to be anonymous", style: .default, handler: { (action) in
                //update the priority level in the database
                self.ref.child("List").child(self.listID!).child("privacy").setValue("the public but I want to be anonomous")
                if let cell = tableView.cellForRow(at: indexPath) {
                    cell.detailTextLabel?.text = "the public but I want to be anonomous"
                }
            }))
            alert.addAction(UIAlertAction(title: "the public", style: .default, handler: { (action) in
                //update the priority level in the database
                self.ref.child("List").child(self.listID!).child("privacy").setValue("the public")
                if let cell = tableView.cellForRow(at: indexPath) {
                    cell.detailTextLabel?.text = "the public"
                }
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
                
                // delete the list in database
                self.ref.child("List").child(self.listID!).removeValue()
                // including deadlineList, priorityList and tagList
                self.ref.child("PriorityList").child(self.user.userID).child(self.settings["Priority level"] as! String).child(self.listID!).removeValue()
                self.ref.child("DeadlineList").child(self.user.userID).child(self.listID!).removeValue()
                // MARK: todo: delete from tagList and collaborators' access
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
        
        newDdl = "\(dateString)"
        print(newDdl!)
        alert.textFields?[0].text = newDdl
        self.view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToTagSettings"{
            if let destination = segue.destination as? TagsTableViewController {
                destination.listID = listID
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
                if let collaborators = ref.child("List").child(listID!).value(forKey: "collaborator") as? [String] {
                    destination.collaborators = collaborators
                }
            }
        }
    }
}

