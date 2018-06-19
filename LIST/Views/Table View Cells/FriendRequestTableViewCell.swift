//
//  FriendRequestTableViewCell.swift
//  LIST
//
//  Created by 蔡雨倩 on 19/06/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import UIKit

class FriendRequestTableViewCell: UITableViewCell {

    @IBOutlet weak var iconPic: UIImageView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var infoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
