//
//  SignUpViewController.swift
//  LIST
//
//  Created by 蔡雨倩 on 28/05/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class SignUpViewController: UIViewController ,UITextFieldDelegate {

    lazy var user = LISTUser()
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var codeField: UITextField!
    @IBOutlet weak var rePasswordField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailField.delegate = self
        codeField.delegate = self
        passwordField.delegate = self
        rePasswordField.delegate = self
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.count == 0 {
            return true
        }
        
        let currentText = textField.text ?? ""
        let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        switch textField {
            case passwordField:
                return prospectiveText.count <= 20
            case rePasswordField:
                return prospectiveText.count <= 20
            default:
                return true
        }
    }
    
    private func isInputValid() -> Int {
        if passwordField.text != rePasswordField.text && passwordField.text != nil {
            return 1
        } else if passwordField.text == nil {
            return 2
        }
        return 3
    }
    
    // MARK: Create an user
    @IBAction func letsGoTapped(_ sender: UIButton) {
        // check every field is filled corretly
        let checkResult = isInputValid()
        if (checkResult != 3) {
            var errorMessage = String()
            switch checkResult {
            case 1:
                errorMessage = "The password did not match the repassword"
            case 2:
                errorMessage = "The password cannot be empty"
            default:
                break
            }
            let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            
        } else {
            if let email = emailField.text, let password = passwordField.text{
                Auth.auth().createUser(withEmail: email, password: password){ (user, error) in
                    if let error = error{
                        // notify user that the resigistration failed
                        let alert = UIAlertController(title: "Registration Failed",
                                                      message:error.localizedDescription,
                                                      preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        print("user email is \(email)")
                        let ref = Database.database().reference(fromURL: "https://list-caiyuqian.firebaseio.com")
                        ref.child("Profile").child("\(self.user.userID)").child("email").setValue(email)
                        ref.child("UserID").child(email).setValue(self.user.userID)
                        self.user.email = email
                        let today = Date()
                        self.user.createDate = today.toString(dateFormat: "dd-MM-yyyy")
                        self.performSegue(withIdentifier: "goToFillProfile", sender: self)
                    }
                }
            }
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
}
extension Date {
    func toString( dateFormat format  : String ) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
}
