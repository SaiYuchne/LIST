//
//  AddItemTableViewCell.swift
//  LIST
//
//  Created by 蔡雨倩 on 09/06/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import UIKit

class ToolTableViewCell: UITableViewCell {

    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addButton.titleLabel?.font.withSize(addButton.bounds.size.height*0.7)
    }

    @IBAction func addButtonTapped(_ sender: UIButton) {
        
    }
    @IBOutlet weak var settingsButtonTapped: UIButton!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
