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
    
    let archiveRef = Database.database().reference().child("Archive")
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureTitleLabel()
        getDataFromDatabase()
        configureLabel()
        configureButton()
    }

    func configureTitleLabel() {
        creationDateTitleLabel.text = "Creation date"
        creationDateTitleLabel.font = UIFont.systemFont(ofSize: creationDateTitleLabel.bounds.size.height * 0.8)
        deadlineTitleLabel.text = "Deadline"
        deadlineTitleLabel.font = UIFont.systemFont(ofSize: deadlineTitleLabel.bounds.size.height * 0.8)
        completionDateTitleLabel.text = "Completion date"
        completionDateTitleLabel.font = UIFont.systemFont(ofSize: completionDateTitleLabel.bounds.size.height * 0.8)
        priorityTitleLabel.text = "Priority"
        priorityTitleLabel.font = UIFont.systemFont(ofSize: priorityTitleLabel.bounds.size.height * 0.8)
        privacyTitleLabel.text = "Privacy"
        privacyTitleLabel.font = UIFont.systemFont(ofSize: privacyTitleLabel.bounds.size.height * 0.8)
        collaboratorTitleLabel.text = "Collaborators"
        collaboratorTitleLabel.font = UIFont.systemFont(ofSize: collaboratorTitleLabel.bounds.size.height * 0.8)
        tagTitleLabel.text = "Tags"
        tagTitleLabel.font = UIFont.systemFont(ofSize: tagTitleLabel.bounds.size.height * 0.8)
    }
    
    func configureLabel() {
        creationDateTitleLabel.font = UIFont.systemFont(ofSize: tagTitleLabel.bounds.size.height * 0.8)
        deadlineTitleLabel.font = UIFont.systemFont(ofSize: deadlineTitleLabel.bounds.size.height * 0.8)
        completionDateTitleLabel.font = UIFont.systemFont(ofSize: completionDateTitleLabel.bounds.size.height * 0.8)
        priorityTitleLabel.font = UIFont.systemFont(ofSize: priorityTitleLabel.bounds.size.height * 0.8)
        privacyTitleLabel.font = UIFont.systemFont(ofSize: privacyTitleLabel.bounds.size.height * 0.8)
    }
    
    func configureButton() {
        collaboratorButton.titleLabel?.font = UIFont.systemFont(ofSize: collaboratorButton.bounds.size.height * 0.8)
        tagButton.titleLabel?.font = UIFont.systemFont(ofSize: tagButton.bounds.size.height * 0.8)
        viewDetailButton.titleLabel?.font = UIFont.systemFont(ofSize: viewDetailButton.bounds.size.height * 0.8)
    }
    
    // MARK: database operations
    func getDataFromDatabase() {
        archiveRef.child(listID!).observeSingleEvent(of: .value) { (snapshot) in
            if let tempData = snapshot.value as? Dictionary<String, Any> {
                self.creationDateTitleLabel.text = tempData["creationDate"] as? String
                self.deadlineTitleLabel.text = tempData["deadline"] as? String
                self.completionDateTitleLabel.text = tempData["completionDate"] as? String
                self.priorityTitleLabel.text = tempData["priority"] as? String
                self.privacyTitleLabel.text = tempData["privacy"] as? String
            }
        }
    }
    
}
