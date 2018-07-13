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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewByPriority" {
            if let destination = segue.destination as? ViewListViewController {
                destination.byPriority = true
            }
        } else if segue.identifier == "viewByDeadline" {
            if let destination = segue.destination as? ViewListViewController {
                destination.byDeadline = true
            }
        } else {
            ref.child("TagList").child(user.userID).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.value == nil {
                    let alert = UIAlertController(title: "Sorry", message: "You haven't added any tags to your lists. You may view your lists by priority level or deadline and then add some tags to your lists.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    if let destination = segue.destination as? ViewListViewController {
                        destination.byTag = true
                    }
                }
            })
        }
    }

}
