//
//  DocumentNodeViewController.swift
//  LIST
//
//  Created by 蔡雨倩 on 13/06/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import UIKit
import FirebaseDatabase

class DocumentNodeViewController: UIViewController, UITextFieldDelegate{

    let ref = Database.database().reference()
    var itemID: String?
    var nodeID: String?
    
    @IBOutlet weak var dateTextField: UITextField!
    
    @IBOutlet weak var descriptionTextView: UITextView!
    
    var addNode = true
    
    let picker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dateTextField.delegate = self
        createDatePicker()
        if !addNode {
            getDataFromDatabase()
        }
    }

    @IBAction func saveTapped(_ sender: UIButton) {
        if addNode {
            // create new entry in the database
            addNewNodeInDatabase()
            let alert = UIAlertController(title: "Added", message: "Add the node successfully!", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        } else {
            // update the documentation in the database
            editNewNodeInDatabase()
            let alert = UIAlertController(title: "Edited", message: "Edit the node successfully!", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
        
    }
    
    // MARK: Set the date picker with a tool bar
    func createDatePicker(){
        
        // toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        // done button for toolbar
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolbar.setItems([done], animated: false)
        
        dateTextField.inputAccessoryView = toolbar
        dateTextField.inputView = picker
        
        // format picker for date
        picker.datePickerMode = .date
    }
    
    @objc func donePressed() {
        // format date
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        let dateString = formatter.string(from: picker.date)
        
        dateTextField.text = "\(dateString)"
        self.view.endEditing(true)
        print("user birthDate is \(dateString)")
    }
    
    @IBAction func deleteTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Warning", message: "Delete this node?", preferredStyle: .alert)
        let no = UIAlertAction(title: "No", style: .cancel, handler: nil)
        let yes = UIAlertAction(title: "Yes", style: .default) { (_) in
            // delete data from the database
            self.deleteNodeInDatabase()
            // go back to the previous page
            _ = self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(no)
        alert.addAction(yes)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: Dismiss the keyboard
    // when touching outside
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    // when pressing return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: database operations
    func getDataFromDatabase() {
        ref.child("Progress").child(itemID!).child(nodeID!).observe(.value) { (snapshot) in
            if let nodeInfo = snapshot.value as? [String: String] {
                let date = nodeInfo["date"]
                let content = nodeInfo["content"]
                self.dateTextField.text = date
                self.descriptionTextView.text = content
            }
        }
    }
    
    func addNewNodeInDatabase() {
        let progressRef = ref.child("Progress").child(itemID!)
        let nodeID = progressRef.childByAutoId().key
        
        let nodeInfo = ["date": dateTextField.text!, "content": descriptionTextView.text, "creationDays": Date().timeIntervalSinceReferenceDate] as [String: Any]
        progressRef.child(nodeID).setValue(nodeInfo)
    }
    
    func editNewNodeInDatabase() {
        let nodeRef = ref.child("Progress").child(itemID!).child(nodeID!)
        
        let nodeInfo = ["date": dateTextField.text!, "content": descriptionTextView.text] as [String: Any]
        nodeRef.setValue(nodeInfo)
    }

    func deleteNodeInDatabase() {
        ref.child("Progress").child(itemID!).child(nodeID!).removeValue()
    }
}
