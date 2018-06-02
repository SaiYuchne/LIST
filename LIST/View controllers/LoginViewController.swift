//
//  LoginViewController.swift
//  LIST
//
//  Created by 蔡雨倩 on 28/05/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailField.delegate = self
        passwordField.delegate = self
        
        // monitor a user’s authentication state
        Auth.auth().addStateDidChangeListener() { (auth, user) in
            if user != nil {
                print("user is not nil")
                self.performSegue(withIdentifier: "goToHomePage", sender: self)
                self.emailField.text = nil
                self.passwordField.text = nil
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
    
    // MARK: loginButtonTapped
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        
        // form validation on email and password
        if let email = emailField.text, let password = passwordField.text {
            Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                if let _ = user {
                    // user is found, go to personal page
                    self.performSegue(withIdentifier: "goToHomePage", sender: self)
                }else if let error = error{
                    // login failed
                    let alert = UIAlertController(title: "Sign In Failed",
                                            message:error.localizedDescription,
                                            preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
}
