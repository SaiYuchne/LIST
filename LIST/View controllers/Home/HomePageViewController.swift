//
//  HomePageViewController.swift
//  LIST
//
//  Created by 蔡雨倩 on 02/06/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class HomePageViewController: UIViewController {
    
    let ref = Database.database().reference()
    var user = LISTUser()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        let connectedRef = Database.database().reference(withPath: ".info/connected")
        connectedRef.observe(.value, with: { snapshot in
            if snapshot.value as? Bool ?? false {
                print("Connected")
            } else {
                print("Not connected")
            }
        })
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user == nil {
                self.present(LoginViewController(), animated: false, completion: {
                    print("user is nil")
                })
            }
            print("user is not nil, userID is \(self.user.userID)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBOutlet weak var profileExtract: ProfileExtractView!{
        didSet{
            let tap = UITapGestureRecognizer(target: self, action: #selector(profileExtractTapped(_: )))
            profileExtract.addGestureRecognizer(tap)
        }
    }
    
    @objc func profileExtractTapped(_ recognizer: UITapGestureRecognizer){
        switch recognizer.state {
        case .ended:
            UIView.transition(with: profileExtract, duration: 0.6, options: .transitionFlipFromLeft, animations: { self.profileExtract.isFaceUp = !self.profileExtract.isFaceUp})
        default:
            break
        }
    }
  
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "goToProfilePage", sender is UIButton{
            return false
        }
        return true
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
}
