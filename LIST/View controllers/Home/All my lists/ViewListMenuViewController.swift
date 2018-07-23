//
//  ViewListMenuViewController.swift
//  LIST
//
//  Created by 蔡雨倩 on 11/06/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ViewListMenuViewController: UIViewController {
    
    let user = LISTUser()
    let ref = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        print("Check: should perform segue:")
        var shouldPerform = true
        
        if identifier == "viewByPriority" {
            print("viewByPriority")
            ref.child("PriorityList").child(user.userID).observeSingleEvent(of: .value, with: { (snapshot) in
                if !snapshot.exists() {
                    print("snapshot does not exist")
                    shouldPerform = false
                    let alert = UIAlertController(title: "Sorry", message: "You haven't created any list. You can go to create one and then come back.", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                        self.navigationController?.popViewController(animated: true)
                    })
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                }
            })
        } else if identifier == "viewByDeadline" {
            print("viewByDeadline")
            ref.child("DeadlineList").child(user.userID).observeSingleEvent(of: .value, with: { (snapshot) in
                if !snapshot.exists() {
                    print("snapshot does not exist")
                    shouldPerform = false
                    let alert = UIAlertController(title: "Sorry", message: "You haven't created any list. You can go to create one and then come back.", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                        self.navigationController?.popViewController(animated: true)
                    })
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                }
            })
        } else {
            print("viewByTag")
            ref.child("TagList").child(user.userID).observeSingleEvent(of: .value, with: { (snapshot) in
                if !snapshot.exists() {
                    print("snapshot does not exist")
                    shouldPerform = false
                    let alert = UIAlertController(title: "Sorry", message: "You haven't added any tags to your lists or haven't created a list before. You may view your lists by priority level or deadline and then add some tags to your lists.", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                        self.navigationController?.popViewController(animated: true)
                    })
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                }
            })
        }
        
        return shouldPerform
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewByPriority" {
            if let destination = segue.destination as? ViewListViewController {
                destination.byTag = true
            }
        } else if segue.identifier == "viewByDeadline" {
            if let destination = segue.destination as? ViewListViewController {
                destination.byDeadline = true
            }
        } else {
            if let destination = segue.destination as? ViewListViewController {
                destination.byTag = true
            }
        }
    }

}
