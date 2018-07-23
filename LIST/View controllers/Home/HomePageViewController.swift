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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let connectedRef = Database.database().reference(withPath: ".info/connected")
        connectedRef.observe(.value, with: { snapshot in
            if snapshot.value as? Bool ?? false {
                print("Connected")
            } else {
                print("Not connected")
            }
        })
        
        if Auth.auth().currentUser?.uid == nil {
            print("user is nil")
            self.present(LoginViewController(), animated: false, completion: nil)
        } else {
            print("user is not nil, userID is \(self.user.userID)")
        }
        
        ref.child("Profile").child(user.userID).observeSingleEvent(of: .value, with: { (snapshot) in
            print("trying to get in...")
            if let tempData = snapshot.value as? [String: Any] {
                print("get in!")
                self.profileExtract.userName = tempData["userName"] as! String
                print("userName is \(tempData["userName"] as! String)")
                self.profileExtract.motto = tempData["motto"] as? String
                if let motto = tempData["motto"] as? String {
                    print("motto is \(motto)")
                }
                self.profileExtract.creationDays = tempData["creationDays"] as! Int
                print("creationDays is \(tempData["creationDays"] as! Int)")
            }
            
        })
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref.child("Profile").child(user.userID).child("pic").observeSingleEvent(of: .value, with: {(snapshot) in
            if let profileImageURL = snapshot.value as? String {
                let url = URL(fileURLWithPath: profileImageURL)
                URLSession.shared.dataTask(with: url, completionHandler: {(data, response, error) in
                    if error != nil {
                        print(error!)
                        return
                    }
                    DispatchQueue.main.async {
                        self.profileExtract.iconImage = UIImage(data: data!)
                    }
                }).resume()
            }
        })
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
        print("Check: should perform segue:")
        if identifier == "goToProfilePage", sender is UIButton{
            return false
        } else if identifier == "goToViewFavLists" {
            var shouldPerform = true
            ref.child("FavouriteList").child(user.userID).observeSingleEvent(of: .value, with: { (snapshot) in
                if !snapshot.exists() {
                    print("snapshot does not exist")
                    shouldPerform = false
                    let alert = UIAlertController(title: "Sorry", message: "You haven't archived any other people's list. You can go to Inspiration Pool for surprise!", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                        self.navigationController?.popViewController(animated: true)
                    })
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                }
            })
            
            return shouldPerform
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToArchive" {
            if let destination = segue.destination as? PageViewController {
                let tryDatabase = ref.child("Archive").child(user.userID).queryOrdered(byChild: "completionDate")
                tryDatabase.observeSingleEvent(of: .value, with: { (snapshot) in
                    if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                        for snap in snapshots {
                            destination.listIDs.append(snap.key)
                        }
                    }
                })
            }
        }
    }
    
    @IBAction func signOutTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Sign out", message: "Are you sure to sign out?", preferredStyle: .alert)
        let yes = UIAlertAction(title: "Yes", style: .destructive) { (action) in
            do {
                try Auth.auth().signOut()
                self.performSegue(withIdentifier: "afterSignOut", sender: self)
            } catch let error {
                print(error)
            }
        }
        let no = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alert.addAction(yes)
        alert.addAction(no)
        present(alert, animated: true, completion: nil)
    }
}
