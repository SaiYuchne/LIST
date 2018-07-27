//
//  SubgoalOverviewTableViewCell.swift
//  LIST
//
//  Created by 蔡雨倩 on 26/07/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import UIKit

class SubgoalOverviewTableViewCell: UITableViewCell {

    @IBOutlet weak var subgoalLabel: UILabel!
    
    var subgoalID: String?
    var itemID: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
