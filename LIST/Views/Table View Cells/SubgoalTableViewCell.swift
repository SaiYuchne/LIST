//
//  SubgoalTableViewCell.swift
//  LIST
//
//  Created by 蔡雨倩 on 15/06/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import UIKit
import FirebaseDatabase

class SubgoalTableViewCell: UITableViewCell {

    @IBOutlet weak var completeGoalButton: UIButton!
    
    @IBOutlet weak var subgoalLabel: UILabel!
    
    let ref = Database.database().reference()
    var subgoalID: String?
    var itemID: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }


    @IBAction func completeGoalButtonTapped(_ sender: Any) {
        if completeGoalButton.titleLabel?.text == "⚪️" {
            print("from cell")
            completeGoalButton.setTitle("✔️", for: .normal)
            ref.child("Subgoal").child(itemID!).child(subgoalID!).child("isFinished").setValue(true)
        } else {
            print("from cell")
            completeGoalButton.setTitle("⚪️", for: .normal)
            ref.child("Subgoal").child(itemID!).child(subgoalID!).child("isFinished").setValue(false)
        }
    }
    
}
