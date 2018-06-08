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

class SignUpViewController: UIViewController ,UITextFieldDelegate{

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
    
    // MARK: Create an user
    @IBAction func letsGoTapped(_ sender: UIButton) {
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
                    ref.child("profile").childByAutoId().child("\(self.user.userID)").childByAutoId().child("email").childByAutoId().setValue(email)
                    self.user.email = email
                    self.performSegue(withIdentifier: "goToFillProfile", sender: self)
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
