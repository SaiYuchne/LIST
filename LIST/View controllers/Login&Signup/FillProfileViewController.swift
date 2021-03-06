//
//  FillProfileViewController.swift
//  LIST
//
//  Created by 蔡雨倩 on 27/05/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class FillProfileViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    var user = LISTUser()
    let ref = Database.database().reference()
    
    @IBOutlet weak var dateField: UITextField!
    
    @IBOutlet weak var nameField: UITextField!
    
    @IBOutlet weak var genderField: UITextField!
    
    // motto is not compulsory
    @IBOutlet weak var mottoField: UITextField!
    
    let picker = UIDatePicker()
    
    let genderPicker = UIPickerView()
    let genders = ["Male", "Female"]
    
    let nameForbiddenCharactersSet = "`~!@#$%^&*()-+=|\\}]{[:;\"'?/>.<,"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createDatePicker()
        configureGenderPicker()
        
        genderPicker.delegate = self
        genderPicker.dataSource = self
        nameField.delegate = self
        dateField.delegate = self
        genderField.delegate = self
        mottoField.delegate = self
        
        genderField.inputView = genderPicker
        
        // set the default value
        genderPicker.selectRow(0, inComponent: 0, animated: false)
        genderField.text = genders[0]
        print("genderField.text = \(genderField.text)")
        if let gender = genderField.text {
            user.gender = gender
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.count == 0 {
            return true
        }
        
        let currentText = textField.text ?? ""
        let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        switch textField {
        case nameField:
            return prospectiveText.count <= 20 && prospectiveText.doesNotContainCharactersIn(matchCharacters: nameForbiddenCharactersSet)
        case mottoField:
            return prospectiveText.count <= 50
        default:
            return true
        }
    }

    func configureGenderPicker() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        // done button for toolbar
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(genderDonePressed))
        toolbar.setItems([done], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        genderField.inputAccessoryView = toolbar
        genderField.inputView = genderPicker
    }
    
    // MARK: Set the date picker with a tool bar
    func createDatePicker(){
        
        // toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        // done button for toolbar
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolbar.setItems([done], animated: false)
        
        dateField.inputAccessoryView = toolbar
        dateField.inputView = picker
        
        // format picker for date
        picker.datePickerMode = .date
    }
    
    @objc func genderDonePressed() {
        self.view.endEditing(true)
    }
    
    @objc func donePressed() {
        // format date
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        let dateString = formatter.string(from: picker.date)
        
        dateField.text = "\(dateString)"
        print("user birthDate is \(dateString)")
        user.birthDate = dateString
        self.view.endEditing(true)
        
    }
    
    // MARK: Set the gender picker
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genders.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genders[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        genderField.text = genders[row]
        genderPicker.resignFirstResponder()
        if let text = genderField.text{
            print("user gender is \(text)")
            user.gender = text
        }
    }
    
    private func isInputValid() -> Int {
        if dateField.text == nil {
            return 1
        } else if nameField.text == nil {
            return 2
        }
        return 3
    }
    
    // MARK: I'm ready tapped
    @IBAction func imReadyTapped(_ sender: UIButton) {
        let checkResult = isInputValid()
        if (checkResult != 3) {
            var errorMessage = String()
            switch checkResult {
            case 1:
                errorMessage = "Please provide your birthday date"
            case 2:
                errorMessage = "Please give yourself a user name"
            default:
                break
            }
            let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            
        } else {
            if let userName = nameField.text {
                user.userName = userName
            } else {
                user.userName = "userName"
            }
            
            if let motto = mottoField.text {
                user.motto = motto
            }
            self.performSegue(withIdentifier: "goToHomePageAfterSignUp", sender: self)
        }
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToHomePageAfterSignUp" {
            if let destination = segue.destination as? HomePageViewController {
                destination.profileExtract.userName = nameField.text!
                destination.profileExtract.motto = mottoField.text
                ref.child("Profile").child(user.userID).child("creationDays").observeSingleEvent(of: .value, with: { (snapshot) in
                        destination.profileExtract.creationDays = snapshot.value as! Int
                })
            }
        }
    }
}
