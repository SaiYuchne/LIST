//
//  ListParticipantsTableViewController.swift
//  LIST
//
//  Created by 蔡雨倩 on 26/07/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ListParticipantsTableViewController: UITableViewController {

    let ref = Database.database().reference()
    var participants = [String]() // IDs
    let user = LISTUser()
    var listID: String?
    
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return participants.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell") as! FriendTableViewCell
        cell.cellView.layer.cornerRadius = cell.cellView.frame.height / 2
        ref.child("Profile").child(participants[indexPath.row]).observeSingleEvent(of: .value, with: { (snapshot) in
            if let collaboratorInfo = snapshot.value as? [String: Any] {
                cell.userNameLabel.text = collaboratorInfo["userName"] as! String
                cell.mottoLabel.text = collaboratorInfo["motto"] as? String
                cell.iconPic.image = UIImage(named: "icon")
                cell.iconPic.layer.cornerRadius = cell.iconPic.frame.height / 2
                cell.iconPic.clipsToBounds = true
            }
        })
        return cell
    }

//    override func tableView(_ tableView: UITableView, canEditRowAt indexPath:
//        return false
//    }

}
