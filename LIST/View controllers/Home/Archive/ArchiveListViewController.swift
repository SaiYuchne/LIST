//
//  ArchiveListViewController.swift
//  LIST
//
//  Created by 蔡雨倩 on 21/06/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ArchiveListViewController: UIViewController {
    
    let listRef = Database.database().reference().child("List")
    var listID: String?
    
    @IBOutlet weak var listTitleLabel: UILabel!
    @IBOutlet weak var creationDateTitleLabel: UILabel!
    @IBOutlet weak var creationDateLabel: UILabel!
    @IBOutlet weak var deadlineTitleLabel: UILabel!
    @IBOutlet weak var deadlineLabel: UILabel!
    @IBOutlet weak var completionDateTitleLabel: UILabel!
    @IBOutlet weak var completionDateLabel: UILabel!
    @IBOutlet weak var priorityTitleLabel: UILabel!
    @IBOutlet weak var priorityLabel: UILabel!
    @IBOutlet weak var privacyTitleLabel: UILabel!
    @IBOutlet weak var privacyLabel: UILabel!
    @IBOutlet weak var collaboratorTitleLabel: UILabel!
    @IBOutlet weak var collaboratorButton: UIButton!
    @IBOutlet weak var tagTitleLabel: UILabel!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var viewDetailButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        listRef.child(listID!).observeSingleEvent(of: .value) { (snapshot) in
            if let tempData = snapshot.value as? [String: Any] {
                self.creationDateLabel.text = tempData["creationDate"] as? String
                self.deadlineLabel.text = tempData["deadline"] as? String
                self.completionDateLabel.text = tempData["completionDate"] as? String
                self.priorityLabel.text = tempData["priority"] as? String
                self.privacyLabel.text = tempData["privacy"] as? String
                self.listTitleLabel.text = tempData["listTitle"] as? String
            }
        }
        configureTitleLabel()
        configureLabel()
        configureButton()
    }
    
    func configureTitleLabel() {
        creationDateTitleLabel.text = "Creation date"
        creationDateTitleLabel.font = UIFont.systemFont(ofSize: creationDateTitleLabel.bounds.size.height * 0.3)
        deadlineTitleLabel.text = "Deadline"
        deadlineTitleLabel.font = UIFont.systemFont(ofSize: deadlineTitleLabel.bounds.size.height * 0.3)
        completionDateTitleLabel.text = "Completion date"
        completionDateTitleLabel.font = UIFont.systemFont(ofSize: completionDateTitleLabel.bounds.size.height * 0.3)
        priorityTitleLabel.text = "Priority"
        priorityTitleLabel.font = UIFont.systemFont(ofSize: priorityTitleLabel.bounds.size.height * 0.3)
        privacyTitleLabel.text = "Privacy"
        privacyTitleLabel.font = UIFont.systemFont(ofSize: privacyTitleLabel.bounds.size.height * 0.3)
        collaboratorTitleLabel.text = "Collaborators"
        collaboratorTitleLabel.font = UIFont.systemFont(ofSize: collaboratorTitleLabel.bounds.size.height * 0.3)
        tagTitleLabel.text = "Tags"
        tagTitleLabel.font = UIFont.systemFont(ofSize: tagTitleLabel.bounds.size.height * 0.3)
        listTitleLabel.font = UIFont.systemFont(ofSize: listTitleLabel.bounds.size.height * 0.7)
    }
    
    func configureLabel() {
        creationDateLabel.font = UIFont.systemFont(ofSize: creationDateLabel.bounds.size.height * 0.3)
        deadlineLabel.font = UIFont.systemFont(ofSize: deadlineLabel.bounds.size.height * 0.3)
        completionDateLabel.font = UIFont.systemFont(ofSize: completionDateLabel.bounds.size.height * 0.3)
        priorityLabel.font = UIFont.systemFont(ofSize: priorityLabel.bounds.size.height * 0.3)
        privacyLabel.font = UIFont.systemFont(ofSize: privacyLabel.bounds.size.height * 0.3)
    }
    
    func configureButton() {
        collaboratorButton.titleLabel?.font = UIFont.systemFont(ofSize: collaboratorButton.bounds.size.height * 0.3)
        tagButton.titleLabel?.font = UIFont.systemFont(ofSize: tagButton.bounds.size.height * 0.3)
        viewDetailButton.titleLabel?.font = UIFont.systemFont(ofSize: viewDetailButton.bounds.size.height * 0.8)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToSeeParticipants" {
            if let destination = segue.destination as? ListParticipantsTableViewController {
                listRef.child(listID!).child("collaborator").observe(.value, with: { (snapshot) in
                    if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                        destination.participants.removeAll()
                        for snap in snapshots {
                            destination.participants.append(snap.key)
                        }
                        self.listRef.child(self.listID!).child("userID").observe(.value, with: { (snapshot) in
                            destination.participants.append(snapshot.value as! String)
                            destination.tableView.reloadData()
                        })
                    }
                })
            }
        }
    }
}
