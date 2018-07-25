//
//  ListItemTableViewCell.swift
//  LIST
//
//  Created by 蔡雨倩 on 09/06/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ListItemTableViewCell: UITableViewCell {

    @IBOutlet weak var completeButton: UIButton!
    
    @IBOutlet weak var goalLabel: UILabel!
    
    @IBOutlet weak var goalSettingsButton: UIButton!
    
    let ref = Database.database().reference()
    var itemID: String?
    var listID: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func completeButtonTapped(_ sender: Any) {
        if completeButton.titleLabel?.text == "🔲" {
            print("from cell")
            ref.child("ListItem").child(listID!).child(itemID!).child("isFinished").setValue(true)
            completeButton.setTitle("✔️", for: .normal)
        } else {
            print("from cell")
            ref.child("ListItem").child(listID!).child(itemID!).child("isFinished").setValue(false)
            completeButton.setTitle("🔲", for: .normal)
        }
    }
    
}
