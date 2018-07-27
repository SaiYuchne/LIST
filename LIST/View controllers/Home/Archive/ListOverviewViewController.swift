//
//  ListOverviewViewController.swift
//  LIST
//
//  Created by 蔡雨倩 on 26/07/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ListOverviewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let ref = Database.database().reference()
    private var user = LISTUser()
    
    struct listCellData {
        var opened = Bool()
        
        var itemID = String()
        var title = String()
        
        var subgoalID = [String]()
        var sectionData = [String]()
    }
    
    var goalData = [listCellData]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var listNameLabel: UILabel!
    
    var listName: String?
    var listID: String?
    var selectedWishIndex: Array<Any>.Index?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        configureListNameLabel(listNameLabel)
    }
    
    func configureListNameLabel(_ label: UILabel){
        if let name = listName {
            listNameLabel.attributedText = centeredAttributedString(name, fontSize: listNameLabel.bounds.size.height * 0.7)
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
        return goalData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if goalData[section].opened{
            return goalData[section].sectionData.count + 1
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            if indexPath.row == 0 {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "listItemOverviewCell") as? GoalOverviewTableViewCell else {return UITableViewCell()}
                cell.goalLabel.text = goalData[indexPath.section].title
                cell.listID = listID
                cell.itemID = goalData[indexPath.section].itemID
                return cell
            } else {
                print("configuring a subgoalCell..")
                print("section = \(indexPath.section), row = \(indexPath.row)")
                let indexData = indexPath.row - 1
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "subgoalOverviewCell") as? SubgoalOverviewTableViewCell else {return UITableViewCell()}
                cell.subgoalLabel.text = goalData[indexPath.section].sectionData[indexData]
                print("subgoal = \(goalData[indexPath.section].sectionData[indexData])")
                cell.itemID = goalData[indexPath.section].itemID
                cell.subgoalID = goalData[indexPath.section].subgoalID[indexData]
                return cell
            }
    }
    
    // MARK: expand to show subgoals
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            if goalData[indexPath.section].opened {
                print("section\(indexPath.section) closing...")
                goalData[indexPath.section].opened = false
                let sections = IndexSet.init(integer: indexPath.section)
                tableView.reloadSections(sections, with: .none)
            } else {
                print("section\(indexPath.section) opening...")
                goalData[indexPath.section].opened = true
                let sections = IndexSet.init(integer: indexPath.section)
                tableView.reloadSections(sections, with: .none)
            }
        }
    }
    
    @IBAction func seeProgressTapped(_ sender: UIButton) {
        if let superView = sender.superview?.superview as? GoalOverviewTableViewCell {
            let goalID = superView.itemID!
            for index in self.goalData.indices {
                if self.goalData[index].itemID == goalID {
                    self.selectedWishIndex = index
                }
            }
        }
        if(shouldPerformSegue(withIdentifier: "goToProgressOverview", sender: self)) {
            self.performSegue(withIdentifier: "goToProgressOverview", sender: self)
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        var shouldPerform = true
        if identifier == "goToProgressOverview", sender is ListOverviewViewController {
            ref.child("Progress").child(goalData[selectedWishIndex!].itemID).observeSingleEvent(of: .value, with: { (snapshot) in
                if !snapshot.exists() {
                    shouldPerform = false
                    let alert = UIAlertController(title: "Sorry", message: "You haven't left any progress for this goal.", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                        self.navigationController?.popViewController(animated: true)
                        
                    })
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                }
                print("the snapshot exist")
            })
        }
        return shouldPerform
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToProgressOverview" {
            if let destination = segue.destination as? ProgressOverviewViewController {
                destination.listID = listID!
                destination.itemID = goalData[selectedWishIndex!].itemID
                destination.itemName = goalData[selectedWishIndex!].title
            }
        }
    }
}
