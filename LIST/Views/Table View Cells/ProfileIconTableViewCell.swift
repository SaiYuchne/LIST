//
//  ProfileIconTableViewCell.swift
//  LIST
//
//  Created by 蔡雨倩 on 18/07/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import UIKit
import Firebase

class ProfileIconTableViewCell: UITableViewCell {

    @IBOutlet weak var iconImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setUpImage()
    }

    func setUpImage() {
        iconImage.layer.cornerRadius = iconImage.bounds.size.height * 0.1
        iconImage.clipsToBounds = true
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
