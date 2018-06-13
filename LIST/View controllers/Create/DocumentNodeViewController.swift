//
//  DocumentNodeViewController.swift
//  LIST
//
//  Created by 蔡雨倩 on 13/06/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import UIKit

class DocumentNodeViewController: UIViewController, UITextFieldDelegate{

    @IBOutlet weak var dateTextField: UITextField!
    
    @IBOutlet weak var descriptionTextView: UITextView!
    
    let picker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dateTextField.delegate = self
        // Do any additional setup after loading the view.
    }

    @IBAction func saveTapped(_ sender: UIButton) {
    }
    
    @IBAction func backTapped(_ sender: Any) {
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
}
