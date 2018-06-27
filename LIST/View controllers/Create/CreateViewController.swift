//
//  CreateViewController.swift
//  LIST
//
//  Created by 蔡雨倩 on 08/06/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import UIKit
import FirebaseDatabase

class CreateViewController: UIViewController, UITextFieldDelegate,  UIPickerViewDelegate, UIPickerViewDataSource {
    
    let ref = Database.database().reference()
    
    @IBOutlet weak var listTitleTextField: UITextField!
    @IBOutlet weak var priorityLevelTextField: UITextField!
    @IBOutlet weak var deadlineTextField: UITextField!
    @IBOutlet weak var privacyLevelTextField: UITextField!
    
    var listID: String?
    var listName: String?
    var privacyLevel: String?
    var deadline: String?
    var priorityLevel: String?
    
    let picker = UIDatePicker()
    let priorityPicker = UIPickerView()
    let priority = ["⭐️", "⭐️⭐️", "⭐️⭐️⭐️", "⭐️⭐️⭐️⭐️", "⭐️⭐️⭐️⭐️⭐️"]
    let privacyPicker = UIPickerView()
    let privacy = ["only me", "friends", "the public but I want to be anonymous", "the public"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        createDatePicker()
        
        configureDoneButtonForPrivacy()
        configureDoneButtonForPriority()
        
        priorityPicker.delegate = self
        priorityPicker.dataSource = self
        privacyPicker.delegate = self
        privacyPicker.dataSource = self
        listTitleTextField.delegate = self
        priorityLevelTextField.delegate = self
        deadlineTextField.delegate = self
        privacyLevelTextField.delegate = self
        
        priorityPicker.accessibilityIdentifier = "priority"
        privacyPicker.accessibilityIdentifier = "privacy"
    }

    // MARK: set up the picker views
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.accessibilityIdentifier == "priority" {
            return priority.count
        } else {
            return privacy.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.accessibilityIdentifier == "priority" {
            return priority[row]
        } else {
            return privacy[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.accessibilityIdentifier == "priority" {
            priorityLevelTextField.text = priority[row]
            priorityPicker.resignFirstResponder()
            if let text = priorityLevelTextField.text {
                print("\(text) is chosen for priority")
                priorityLevel = text
            }
        } else {
            privacyLevelTextField.text = privacy[row]
            privacyPicker.resignFirstResponder()
            if let text = privacyLevelTextField.text {
                print("\(text) is chosen for privacy")
                privacyLevel = text
            }
        }
    }
    
    @IBAction func createButtonTapped(_ sender: UIButton) {
        if let text = listTitleTextField.text{
            print("list title is \(text)")
            listName = text
        }
        createListInDatabase()
        performSegue(withIdentifier: "goToCreateList", sender: self)
    }
    
    // MARK: Set the date picker with a tool bar
    func createDatePicker(){
        print("createDatePicker is called")
        // toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        // done button for toolbar
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(deadlineDonePressed))
        toolbar.setItems([done], animated: false)
        
        deadlineTextField.inputAccessoryView = toolbar
        deadlineTextField.inputView = picker
        
        // format picker for date
        picker.datePickerMode = .date
        deadlineTextField.text = deadline
    }
    
    @objc func deadlineDonePressed() {
        print("deadlineDonePressed is called")
        // format date
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        let formatterForDatabase = DateFormatter()
        // MARK: TO DO: format style is not dd-mm-yyyy
        formatterForDatabase.dateFormat = "dd-mm-yyyy"
        let dateString = formatter.string(from: picker.date)
        
        deadline = "\(dateString)"
        print(deadline!)
        deadlineTextField.text = deadline
        self.view.endEditing(true)
    }
    
    func configureDoneButtonForPrivacy() {
        // toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        // done button for toolbar
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(otherDonePressed))
        toolbar.setItems([done], animated: false)
        
        privacyLevelTextField.inputAccessoryView = toolbar
        privacyLevelTextField.inputView = privacyPicker
    }
    
    func configureDoneButtonForPriority() {
        // toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        // done button for toolbar
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(otherDonePressed))
        toolbar.setItems([done], animated: false)
        
        priorityLevelTextField.inputAccessoryView = toolbar
        priorityLevelTextField.inputView = priorityPicker
    }
    
    @objc func otherDonePressed() {
        // MARK: TO DO: the first row cannot be automatically selected
        self.view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToCreateList" {
            if let destination = segue.destination as? SingleListViewController {
                destination.listName = listName
                destination.listID = listID
                destination.isNew = true
            }
        }
    }
    
    // MARK: database operations
    func createListInDatabase(){
        let user = LISTUser()
        
        // check if all the necessary information is collected
        if listName?.count == 0 {
            print("no list name")
            let alert = UIAlertController(title: "Sorry", message: "A list name is needed", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        } else if priorityLevel?.count == 0 {
            print("no priorityLevel")
            let alert = UIAlertController(title: "Sorry", message: "Priority level is needed", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        } else if privacyLevel?.count == 0 {
            print("no privacyLevel")
            let alert = UIAlertController(title: "Sorry", message: "Privacy level is needed", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        } else if deadline == nil {
            print("no deadline")
            let alert = UIAlertController(title: "Sorry", message: "A deadline is needed", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        } else {
            // generates a random key
            let key = ref.child("List").childByAutoId().key
            self.listID = key
            
            // update List
            let defaultListInfo = ["listTitle": listName!, "userID": user.userID, "privacy": privacyLevel!, "priority": priorityLevel!, "creationDate": Date().toString(dateFormat: "dd-MM-yyyy"), "deadline": deadline!, "tag": [String](), "collaborator": [String](), "isFinished": false] as [String : Any?]
            ref.child("List").child(key).setValue(defaultListInfo)
        }
    }

}
