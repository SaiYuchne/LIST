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
    var listName: String?
    var listID: String?
    
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
        print("tableView.numberOfSections = \(tableView.numberOfSections)")
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "favListGoalCell") as? FavListGoalTableViewCell else {return UITableViewCell()}
            print("indexPath.section is \(indexPath.section) \n indexPath.row is \(indexPath.row)")
            cell.goalLabel.text = goalData[indexPath.section].title
            return cell
        } else {
            let indexData = indexPath.row - 1
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "subgoalCell") as? FavListSubgoalTableViewCell else {return UITableViewCell()}
            cell.subgoalLabel.text = goalData[indexPath.section].sectionData[indexData]
            return cell
        }
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
        }
    }
    
    // MARK: database operations
    func getTableViewDataFromDatabase(){
        let listItemRef = ref.child("ListItem").child(listID!)
        
        listItemRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                for snap in snapshots{
                    var tempData = snap.value as! Dictionary<String, Any>
                    let key = snap.key
                    
                    self.goalData.append(cellData(opened: false, itemID: key, title: tempData["content"] as! String, subgoalID: [],  sectionData: []))
                    self.ref.child("Subgoal").child(key).observeSingleEvent(of: .value, with: { (snapshot) in
                        if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                            for snap in snapshots{
                                var tempData = snap.value as! Dictionary<String, Any>
                                self.goalData[self.goalData.count-1].subgoalID.append(snap.key)
                                self.goalData[self.goalData.count-1].sectionData.append(tempData["content"] as! String)
                            }
                        }
                    }) { (error) in
                        print(error.localizedDescription)
                    }
                }
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
}
