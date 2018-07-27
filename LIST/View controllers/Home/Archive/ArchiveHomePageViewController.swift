//
//  ArchiveHomePageViewController.swift
//  LIST
//
//  Created by 蔡雨倩 on 20/06/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ArchiveHomePageViewController: UIViewController {
    
    let ref = Database.database().reference()
    let user = LISTUser()
    
    @IBOutlet weak var archiveHomePageView: ArchiveHomePageView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("ArchiveHomePageViewController: viewWillAppear")
        
        ref.child("Profile").child(user.userID).child("creationDate").observeSingleEvent(of: .value) { (snapshot) in
                self.archiveHomePageView.creationDate = snapshot.value as! String
            self.ref.child("Archive").child("count").child(self.user.userID).observeSingleEvent(of: .value) { (snapshot) in
                if !snapshot.exists() {
                    self.archiveHomePageView.count = 0
                } else {
                    self.archiveHomePageView.count = snapshot.value as! Int
                    print("count = \(snapshot.value as! Int)")
                }
                self.archiveHomePageView.layoutSubviews()
            }
        }
        
    }

}
