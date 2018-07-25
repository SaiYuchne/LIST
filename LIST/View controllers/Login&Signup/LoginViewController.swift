//
//  LoginViewController.swift
//  LIST
//
//  Created by 蔡雨倩 on 28/05/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class LoginViewController: UIViewController, UITextFieldDelegate {

    let ref = Database.database().reference()
    var user = LISTUser()
    
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.delegate = self
        passwordField.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil {
                // User is signed in.
                print("user is not nil, hence the app will be directed to the personal home page")
                self.performSegue(withIdentifier: "goToHomePage", sender: self)
                self.emailField.text = nil
                self.passwordField.text = nil
            }
        }
        
//        if Auth.auth().currentUser?.uid != nil {
//            print("userID is \(Auth.auth().currentUser?.uid)")
//            print("user is not nil, hence the app will be directed to the personal home page")
//            self.performSegue(withIdentifier: "goToHomePage", sender: self)
//            self.dismiss(animated: false, completion: nil)
//            print("check point1")
//            
//        }
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
        print("loginButtonTapped")
        // form validation on email and password
        if emailField.text == nil {
            print("emailField.text == nil")
        }
        if passwordField.text == nil {
            print("passwordField.text == nil")
        }
        if let email = emailField.text, let password = passwordField.text {
            Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                print("checking on the user")
                if user != nil {
                    print("sign-in succeeded, going to perform segue: goToHomePage")
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
    
    @IBAction func signUpTapped(_ sender: Any) {
        performSegue(withIdentifier: "goToSignUp", sender: self)
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        print("Prepare for segue: goToHomePage in LoginViewController")
//        if segue.identifier == "goToHomePage" {
//            print("first layer")
//            if let tabBarVC = segue.destination as? UITabBarController {
//                print("second layer")
//                if let navigationVC = tabBarVC.viewControllers?.first as? UINavigationController {
//                    print("third layer")
//                    if let destination = navigationVC.viewControllers.first as? HomePageViewController {
//                        print("accessing database now...")
////                        Auth.auth().currentUser?.uid
//                        ref.child("Profile").child(user.userID).observeSingleEvent(of: .value, with: { (snapshot) in
//                            print("trying to get in...")
//                            if let tempData = snapshot.value as? [String: Any] {
//                                print("get in!")
//                                destination.profileExtract.userName = tempData["userName"] as! String
//                                print("userName is \(tempData["userName"] as! String)")
//                                destination.profileExtract.motto = tempData["motto"] as? String
//                                if let motto = tempData["motto"] as? String {
//                                    print("motto is \(motto)")
//                                }
//                                destination.profileExtract.creationDays = tempData["creationDays"] as! Int
//                                print("creationDays is \(tempData["creationDays"] as! Int)")
//                            }
//                            
//                        })
//                    }
//                }
//            }
//        }
//    }
}
