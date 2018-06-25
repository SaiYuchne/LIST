//
//  InvitationTableViewCell.swift
//  LIST
//
//  Created by 蔡雨倩 on 23/06/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import UIKit

class InvitationTableViewCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    
    var senderID: String?
    var listID: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
