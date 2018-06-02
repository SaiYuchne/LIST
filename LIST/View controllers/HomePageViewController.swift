//
//  HomePageViewController.swift
//  LIST
//
//  Created by 蔡雨倩 on 02/06/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import UIKit
import FirebaseAuth

class HomePageViewController: UIViewController {
    
    var user = LISTUser()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            print("check begins")
            if user == nil {
                self.present(LoginViewController(), animated: false, completion: {
                    print("user is nil")
                })
            }
        }
        
        print(user.userID + "\n" + user.email)
    }
    
    
    @IBAction func signOutTapped(_ sender: UIButton) {
        // todo: double check if the user wants to sign out
        do {
            try Auth.auth().signOut()
            self.performSegue(withIdentifier: "goToLoginAfterSignOut", sender: self)
        } catch let error {
            print(error)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
