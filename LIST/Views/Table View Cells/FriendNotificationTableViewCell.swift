//
//  FriendNotificationTableViewCell.swift
//  LIST
//
//  Created by 蔡雨倩 on 19/06/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import UIKit
import FirebaseDatabase

class FriendNotificationTableViewCell: UITableViewCell {

    let ref = Database.database().reference()
    private let user = LISTUser()
    
    @IBOutlet weak var addFriendButton: UIButton!
    
    @IBOutlet weak var newRequestButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        ref.child("FriendRequest").child(user.userID).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.value != nil {
                self.newRequestButton.titleLabel?.text = "🔉New request!"
            } else {
                self.newRequestButton.titleLabel?.text = "🔇No request yet"
            }
        }
        
    }
    

}
