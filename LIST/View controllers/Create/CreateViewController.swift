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
    let user = LISTUser()
    
    @IBOutlet weak var listTitleTextField: UITextField!
    @IBOutlet weak var priorityLevelTextField: UITextField!
    @IBOutlet weak var deadlineTextField: UITextField!
    @IBOutlet weak var privacyLevelTextField: UITextField!
    
    var listID: String?
    var listName: String?
    var privacyLevel: String?
    var deadline: String?
    var priorityLevel: String?
    var deadlineDate: Date?
    
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
        
        // set the default value
        priorityPicker.selectRow(0, inComponent: 0, animated: false)
        priorityLevelTextField.text = priority[0]
        priorityLevel = priorityLevelTextField.text
        privacyPicker.selectRow(0, inComponent: 0, animated: false)
        privacyLevelTextField.text = privacy[0]
        privacyLevel = privacyLevelTextField.text
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.count == 0 {
            return true
        }
        
        let currentText = textField.text ?? ""
        let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        switch textField {
        case listTitleTextField:
            return prospectiveText.count <= 20
        default:
            return true
        }
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
    
    private func isInputValid() -> Int {
        if listTitleTextField.text == nil {
            return 1
        } else if deadlineTextField.text == nil {
            return 2
        }
        return 3
    }
    
    @IBAction func createButtonTapped(_ sender: UIButton) {
        // check every field is filled corretly
        let checkResult = isInputValid()
        if (checkResult != 3) {
            var errorMessage = String()
            switch checkResult {
            case 1:
                errorMessage = "The list title cannot be empty"
            case 2:
                errorMessage = "Please provide a deadline"
            default:
                break
            }
            let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            
        } else {
            if let text = listTitleTextField.text{
                print("list title is \(text)")
                listName = text
            }
            createListInDatabase()
            performSegue(withIdentifier: "goToCreateList", sender: self)
        }
    }
    
    // MARK: Set the date picker with a tool bar
    func createDatePicker(){
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
        // format date
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        let formatterForDatabase = DateFormatter()
        // MARK: TO DO: format style is not dd-mm-yyyy
        formatterForDatabase.dateFormat = "dd-MM-yyyy"
        let dateString = formatter.string(from: picker.date)
        deadlineDate = picker.date
        
        deadline = "\(dateString)"
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
        self.view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToCreateList" {
            if let destination = segue.destination as? SingleListViewController {
                destination.listName = listName
                destination.listID = listID
                destination.isNew = true
                destination.isEditable = true
            }
        }
    }
    
    // MARK: database operations
    func createListInDatabase(){
        let user = LISTUser()
        
        // check if all the necessary information is collected
        if listName?.count == 0 {
            let alert = UIAlertController(title: "Sorry", message: "A list name is needed", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        } else if priorityLevel?.count == 0 {
            let alert = UIAlertController(title: "Sorry", message: "Priority level is needed", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        } else if privacyLevel?.count == 0 {
            let alert = UIAlertController(title: "Sorry", message: "Privacy level is needed", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        } else if deadline == nil {
            let alert = UIAlertController(title: "Sorry", message: "A deadline is needed", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        } else {
            // generates a random key
            let key = ref.child("List").childByAutoId().key
            self.listID = key
            
            // update List
            // List section
            let remainingDays = calculateDaysLeft(deadLineString: deadline!)
            let defaultListInfo = ["listTitle": listName!, "userID": user.userID, "privacy": privacyLevel!, "priority": priorityLevel!, "remainingDays": remainingDays, "creationDate": Date().toString(dateFormat: "dd-MM-yyyy"), "deadline": deadline!, "tag": [String: String](), "collaborator": [String: String](), "isFinished": false, "totalNumOfItems": 0, "numOfCompletedItems": 0] as [String : Any?]
            ref.child("List").child(key).setValue(defaultListInfo)
            
            // PriorityList, DeadlineList sections
            ref.child("PriorityList").child(user.userID).child(priorityLevel!).child(listID!).setValue(listID!)
            let deadlineUpdate = ["listTitle": listName!, "deadline": deadline!]
            ref.child("DeadlineList").child(user.userID).child("\(remainingDays)").child(listID!).setValue(deadlineUpdate)
            
            // FriendList section
            if privacyLevel == "friends" {
                ref.child("FriendList").child(user.userID).child(listID!).setValue(listName!)
            }
        }
    }
    
    func calculateDaysLeft(deadLineString: String) -> Int {
        var daysLeft = 0
        let todayInterval = Int(Date().timeIntervalSinceReferenceDate/(3600 * 24))
        let deadlineInterval = Int(deadlineDate!.timeIntervalSinceReferenceDate/(3600 * 24))
    
        daysLeft = deadlineInterval - todayInterval
        
        return daysLeft < 0 ? 0 : daysLeft
    }

}
