//
//  ListSettingsTableViewController.swift
//  LIST
//
//  Created by 蔡雨倩 on 10/06/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import UIKit

class ListSettingsTableViewController: UITableViewController,  UITextFieldDelegate {
    
    let picker = UIDatePicker()
    private var alert = UIAlertController(title: "Edit", message: "Edit your list name:", preferredStyle: .alert)
    var newDdl: String?
    
    private var settingTitle = ["List name", "Creation date", "Deadline", "Priority level", "Who can view this list", "Tags", "Delete this list"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingTitle.count
    }

    /*
        If the list is newly created, use the default setting; otherwise fetch
        it from the databse
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row+1 < settingTitle.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "listSettingsCell", for: indexPath)
            cell.textLabel?.text = settingTitle[indexPath.row]
            switch (indexPath.row){
            case 0:
                cell.accessoryType = .disclosureIndicator
                cell.detailTextLabel?.text = "list name"
            case 1:
                cell.detailTextLabel?.text = "date"
            case 2:
                cell.accessoryType = .disclosureIndicator
                cell.detailTextLabel?.text = "ddl"
            case 3:
                cell.accessoryType = .disclosureIndicator
                cell.detailTextLabel?.text = "important"
            case 4:
                cell.accessoryType = .disclosureIndicator
                cell.detailTextLabel?.text = "personal"
            default:
                cell.accessoryType = .disclosureIndicator
                cell.detailTextLabel?.text = ""
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
                        // change the list name in database
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
            let alert = UIAlertController(title: "Priority level", message: "Please choose the priority level", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "⭐️", style: .default, handler: { (action) in
                //update the priority level in the database
                if let cell = tableView.cellForRow(at: indexPath) {
                    cell.detailTextLabel?.text = "⭐️"
                }
            }))
            alert.addAction(UIAlertAction(title: "⭐️⭐️", style: .default, handler: { (action) in
                //update the priority level in the database
                if let cell = tableView.cellForRow(at: indexPath) {
                    cell.detailTextLabel?.text = "⭐️⭐️"
                }
            }))
            alert.addAction(UIAlertAction(title: "⭐️⭐️⭐️", style: .default, handler: { (action) in
                //update the priority level in the database
                if let cell = tableView.cellForRow(at: indexPath) {
                    cell.detailTextLabel?.text = "⭐️⭐️⭐️"
                }
            }))
            alert.addAction(UIAlertAction(title: "⭐️⭐️⭐️⭐️", style: .default, handler: { (action) in
                //update the priority level in the database
                if let cell = tableView.cellForRow(at: indexPath) {
                    cell.detailTextLabel?.text = "⭐️⭐️⭐️⭐️"
                }
            }))
            alert.addAction(UIAlertAction(title: "⭐️⭐️⭐️⭐️⭐️", style: .default, handler: { (action) in
                //update the priority level in the database
                if let cell = tableView.cellForRow(at: indexPath) {
                    cell.detailTextLabel?.text = "⭐️⭐️⭐️⭐️⭐️"
                }
            }))
            self.present(alert, animated: true, completion: nil)
            tableView.reloadData()
        // MARK: change the privacy level
        case 4:
            let alert = UIAlertController(title: "Privacy level", message: "Who can view this list?", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "only me", style: .default, handler: { (action) in
                //update the priority level in the database
                if let cell = tableView.cellForRow(at: indexPath) {
                    cell.detailTextLabel?.text = "only me"
                }
            }))
            alert.addAction(UIAlertAction(title: "friends", style: .default, handler: { (action) in
                //update the priority level in the database
                if let cell = tableView.cellForRow(at: indexPath) {
                    cell.detailTextLabel?.text = "friends"
                }
            }))
            alert.addAction(UIAlertAction(title: "the public but I want to be anonomous", style: .default, handler: { (action) in
                //update the priority level in the database
                if let cell = tableView.cellForRow(at: indexPath) {
                    cell.detailTextLabel?.text = "the public but I want to be anonomous"
                }
            }))
            alert.addAction(UIAlertAction(title: "the public", style: .default, handler: { (action) in
                //update the priority level in the database
                if let cell = tableView.cellForRow(at: indexPath) {
                    cell.detailTextLabel?.text = "the public"
                }
            }))
            self.present(alert, animated: true, completion: nil)
            tableView.reloadData()
        case 5:
            // perform segue
            self.performSegue(withIdentifier: "goToTagSettings", sender: self)
        case 6:
            let alert = UIAlertController(title: "Delete the list", message: "Are you sure to delete this list?", preferredStyle: .alert)
            let no = UIAlertAction(title: "Don't delete", style: .cancel, handler: nil)
            let yes = UIAlertAction(title: "Delete", style: .default) { (_) in
                // delete the list in database
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
        let dateString = formatter.string(from: picker.date)
        
        newDdl = "\(dateString)"
        print(newDdl)
        alert.textFields?[0].text = newDdl
        self.view.endEditing(true)
    }
}
