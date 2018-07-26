//
//  SystemTagTableViewCell.swift
//  LIST
//
//  Created by 蔡雨倩 on 25/07/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import UIKit

class SystemTagTableViewCell: UITableViewCell {

    @IBOutlet weak var tagLabel: UILabel!
    
    @IBOutlet weak var stateLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
