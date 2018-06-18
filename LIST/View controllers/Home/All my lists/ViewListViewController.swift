//
//  ViewListViewController.swift
//  LIST
//
//  Created by 蔡雨倩 on 11/06/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ViewListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let user = LISTUser()
    let ref = Database.database().reference()
    @IBOutlet weak var tableView: UITableView!
    
    var tableViewData = [cellData]()
    
    var byPriority = false
    var byDeadline = false
    var byTag = false
    
    var chosenSection: Int?
    var chosenRow: Int?
    
    private let priorityLevel = ["1": "⭐️", "2": "⭐️⭐️", "3": "⭐️⭐️⭐️", "4": "⭐️⭐️⭐️⭐️", "5": "⭐️⭐️⭐️⭐️⭐️",]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        getTableViewDataFromDatabase()
        if(byPriority){
            tableViewData = [
                cellData(opened: false, title: "⭐️⭐️⭐️⭐️⭐️", sectionData: ["Cell1", "Cell2", "Cell3"], listID: ["1", "1", "1",]),
                cellData(opened: false, title: "⭐️⭐️⭐️⭐️", sectionData: ["Cell1", "Cell2", "Cell3"], listID: ["1", "1", "1",]),
                cellData(opened: false, title: "⭐️⭐️⭐️", sectionData: ["Cell1", "Cell2", "Cell3"], listID: ["1", "1", "1",]),
                cellData(opened: false, title: "⭐️⭐️", sectionData: ["Cell1", "Cell2", "Cell3"], listID: ["1", "1", "1",]),
                cellData(opened: false, title: "⭐️", sectionData: ["Cell1", "Cell2", "Cell3"], listID: ["1", "1", "1",])]
            byPriority = !byPriority
        } else if (byDeadline){
            tableViewData = [
                cellData(opened: false, title: "2018-07-01", sectionData: ["Cell1", "Cell2", "Cell3"], listID: ["1", "1", "1",]),
                cellData(opened: false, title: "2018-06-29", sectionData: ["Cell1", "Cell2", "Cell3"], listID: ["1", "1", "1",])]
            byDeadline = !byDeadline
        } else {
            tableViewData = [
                cellData(opened: false, title: "animal", sectionData: ["Cell1", "Cell2", "Cell3"], listID: ["1", "1", "1",]),
                cellData(opened: false, title: "books", sectionData: ["Cell1", "Cell2", "Cell3"], listID: ["1", "1", "1",])]
            byTag = !byTag
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableViewData[section].opened {
            return tableViewData[section].sectionData.count + 1
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "listNameCell") else {return UITableViewCell()}
            cell.textLabel?.text = tableViewData[indexPath.section].title
            return cell
        } else {
            let indexData = indexPath.row - 1
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "listNameCell") else {return UITableViewCell()}
            cell.textLabel?.text = tableViewData[indexPath.section].sectionData[indexData]
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            if tableViewData[indexPath.section].opened {
                tableViewData[indexPath.section].opened = false
                let sections = IndexSet.init(integer: indexPath.section)
                tableView.reloadSections(sections, with: .none)
            } else {
                tableViewData[indexPath.section].opened = true
                let sections = IndexSet.init(integer: indexPath.section)
                tableView.reloadSections(sections, with: .none)
            }
        } else {
            chosenSection = indexPath.section
            chosenRow = indexPath.row - 1
            self.performSegue(withIdentifier: "goToAList", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToAList" {
            if let destination = segue.destination as? SingleListViewController {
                destination.listName = tableViewData[chosenSection!].sectionData[chosenRow!]
                destination.listID = tableViewData[chosenSection!].listID[chosenRow!]
            }
        }
    }
    
    func getTableViewDataFromDatabase() {
        if(byPriority){
            let priorityListRef = ref.child("PriorityList").child(user.userID)
            var index = 6
            for _ in 0...5 {
                index -= 1
                priorityListRef.child("5").observeSingleEvent(of: .value, with: { (snapshot) in
                    if let ids = snapshot.value as? [String] {
                        self.tableViewData.append(cellData(opened: false, title: self.priorityLevel["\(index)"]!, sectionData: [String](), listID: ids))
                    }
                })
                for index in tableViewData[tableViewData.count - 1].listID.indices {
                    let listID = tableViewData[tableViewData.count - 1].listID[index]
                    ref.child("List").child(listID).observeSingleEvent(of: .value, with: { (snapshot) in
                        if let tempData = snapshot.value as? Dictionary<String, Any> {
                            let listName = tempData["listTitle"] as? String
                            self.tableViewData[self.tableViewData.count - 1].sectionData.append(listName!)
                        }
                    })
                }
            }
            byPriority = !byPriority
        } else if (byDeadline){
            let deadlineListRef = ref.child("DeadlineList").child(user.userID).queryOrdered(byChild: "deadline")

                deadlineListRef.observeSingleEvent(of: .value, with: { (snapshot) in
                    if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                        for snap in snapshots{
                            let tempData = snap.value as? Dictionary<String, Any>
                            let deadline = tempData!["deadline"] as! String
                            let listTitle = tempData!["listTitle"] as! String
                            if self.tableViewData.count > 0, self.tableViewData[self.tableViewData.count-1].title == deadline {
                                self.tableViewData[self.tableViewData.count-1].sectionData.append(listTitle)
                                self.tableViewData[self.tableViewData.count-1].listID.append(snap.key)
                            } else {
                                self.tableViewData.append(cellData(opened: false, title: deadline, sectionData: [listTitle], listID: [snap.key]))
                            }
                        }
                    }
                })
            byDeadline = !byDeadline
        } else {
            let tagListRef = ref.child("TagList").child(user.userID).queryOrdered(byChild: "tag")
            
            tagListRef.observeSingleEvent(of: .value, with: { (snapshot) in
                if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                    for snap in snapshots{
                        let tempData = snap.value as? Dictionary<String, Any>
                        let tag = tempData!["tag"] as! String
                        let listTitle = tempData!["listTitle"] as! String
                        if self.tableViewData.count > 0, self.tableViewData[self.tableViewData.count-1].title == tag {
                            self.tableViewData[self.tableViewData.count-1].sectionData.append(listTitle)
                            self.tableViewData[self.tableViewData.count-1].listID.append(snap.key)
                        } else {
                            self.tableViewData.append(cellData(opened: false, title: tag, sectionData: [listTitle], listID: [snap.key]))
                        }
                    }
                }
            })
            byTag = !byTag
        }
    }
}

struct cellData{
    var opened = Bool()
    var title = String()
    var sectionData = [String]()
    var listID = [String]()
}
