//
//  SubgoalTableViewCell.swift
//  LIST
//
//  Created by 蔡雨倩 on 15/06/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import UIKit

class SubgoalTableViewCell: UITableViewCell {

    @IBOutlet weak var completeGoalButton: UIButton!
    
    @IBOutlet weak var subgoalLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func completeGoalButtonTapped(_ sender: Any) {
        completeGoalButton.setTitle("✔️", for: .normal)
    }
    
}
