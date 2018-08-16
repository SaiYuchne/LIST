//
//  SingleFavouriteListViewController.swift
//  LIST
//
//  Created by 蔡雨倩 on 09/07/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import UIKit
import FirebaseDatabase

class SingleFavouriteListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let ref = Database.database().reference()
    private lazy var user = LISTUser()
    
    struct cellData{
        var opened = Bool()
        
        var itemID = String()
        var title = String()
        
        var subgoalID = [String]()
        var sectionData = [String]()
    }
    
    var goalData = [cellData]()
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var listNameLabel: UILabel!
    var listID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        configureListNameLabel(listNameLabel)
    }

    func configureListNameLabel(_ label: UILabel){
        ref.child("List").child(listID!).child("listTitle").observeSingleEvent(of: .value) { (snapshot) in
            let listName = snapshot.value as! String
            self.listNameLabel.attributedText = self.centeredAttributedString(listName, fontSize: self.listNameLabel.bounds.size.height * 0.7)
        }
    }
    
    private func centeredAttributedString(_ string: String, fontSize: CGFloat) -> NSAttributedString {
        var font = UIFont.preferredFont(forTextStyle: .body).withSize(fontSize)
        font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        return NSAttributedString(string: string, attributes: [.paragraphStyle:paragraphStyle,.font:font])
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return goalData.count + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < goalData.count, goalData[section].opened{
            return goalData[section].sectionData.count + 1
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section+1 != tableView.numberOfSections{
            if indexPath.row == 0 {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "favListGoalCell") as? FavListGoalTableViewCell else {return UITableViewCell()}
                cell.goalLabel.text = goalData[indexPath.section].title
                return cell
            } else {
                let indexData = indexPath.row - 1
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "subgoalCell") as? FavListSubgoalTableViewCell else {return UITableViewCell()}
                cell.subgoalLabel.text = goalData[indexPath.section].sectionData[indexData]
                return cell
            }
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "seeTagCell", for: indexPath)
        return cell
    }
    
    // MARK: expand to show subgoals
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section+1 != tableView.numberOfSections, indexPath.row == 0 {
            if goalData[indexPath.section].opened {
                goalData[indexPath.section].opened = false
                let sections = IndexSet.init(integer: indexPath.section)
                tableView.reloadSections(sections, with: .none)
            } else {
                goalData[indexPath.section].opened = true
                let sections = IndexSet.init(integer: indexPath.section)
                tableView.reloadSections(sections, with: .none)
            }
        } else if indexPath.section == tableView.numberOfSections - 1 {
            performSegue(withIdentifier: "seeFavListTags", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "seeFavListTags" {
            if let destination = segue.destination as? SimpleListTagTableViewController {
                ref.child("List").child(listID!).child("tag").observe(.value, with: { (snapshot) in
                    if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                        destination.cellTitle.removeAll()
                        for snap in snapshots {
                            destination.cellTitle.append(snap.key)
                        }
                    }
                    destination.tableView.reloadData()
                })
            }
        }
    }
}
