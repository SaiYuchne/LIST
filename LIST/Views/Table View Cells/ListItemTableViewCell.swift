//
//  ListItemTableViewCell.swift
//  LIST
//
//  Created by 蔡雨倩 on 09/06/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import UIKit

class ListItemTableViewCell: UITableViewCell {

    @IBOutlet weak var completeButton: UIButton!
    
    @IBOutlet weak var goalLabel: UILabel!
    
    @IBOutlet weak var goalSettingsButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func completeButtonTapped(_ sender: Any) {
         completeButton.setTitle("✔️", for: .normal)
    }
  
    
}
