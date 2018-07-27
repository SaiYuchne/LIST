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
    
    struct cellData{
        var opened = Bool()
        var title = String()
        var sectionData = [String]()
        var listID = [String]()
    }
    var tableViewData = [cellData]()
    var priorityListsData = [
        cellData(opened: false, title: "⭐️⭐️⭐️⭐️⭐️", sectionData: [String](), listID: [String]()),
        cellData(opened: false, title: "⭐️⭐️⭐️⭐️", sectionData: [String](), listID: [String]()),
        cellData(opened: false, title: "⭐️⭐️⭐️", sectionData: [String](), listID: [String]()),
        cellData(opened: false, title: "⭐️⭐️", sectionData: [String](), listID: [String]()),
        cellData(opened: false, title: "⭐️", sectionData: [String](), listID: [String]())]
    private let priorityLevel = ["1": "⭐️", "2": "⭐️⭐️", "3": "⭐️⭐️⭐️", "4": "⭐️⭐️⭐️⭐️", "5": "⭐️⭐️⭐️⭐️⭐️"]
    
    var deadlineListsData = [cellData]()
    var tagListsData = [
        cellData(opened: false, title: "Animal", sectionData: [String](), listID: [String]()),
        cellData(opened: false, title: "Arts", sectionData: [String](), listID: [String]()),
        cellData(opened: false, title: "Diet", sectionData: [String](), listID: [String]()),
        cellData(opened: false, title: "Family", sectionData: [String](), listID: [String]()),
        cellData(opened: false, title: "Food", sectionData: [String](), listID: [String]()),
        cellData(opened: false, title: "Hobby", sectionData: [String](), listID: [String]()),
        cellData(opened: false, title: "Life", sectionData: [String](), listID: [String]()),
        cellData(opened: false, title: "Mood", sectionData: [String](), listID: [String]()),
        cellData(opened: false, title: "Romance", sectionData: [String](), listID: [String]()),
        cellData(opened: false, title: "Skill", sectionData: [String](), listID: [String]()),
        cellData(opened: false, title: "Sports", sectionData: [String](), listID: [String]()),
        cellData(opened: false, title: "Study", sectionData: [String](), listID: [String]()),
        cellData(opened: false, title: "Travel", sectionData: [String](), listID: [String]()),
        cellData(opened: false, title: "Work", sectionData: [String](), listID: [String]()),
        cellData(opened: false, title: "YOLO", sectionData: [String](), listID: [String]())]
    
    
    var byPriority = false
    var byDeadline = false
    var byTag = false
    
    var chosenSection: Int?
    var chosenRow: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(byPriority) {
            tableViewData[section].sectionData = [String]()
            tableViewData[section].sectionData = priorityListsData[section].sectionData
            tableViewData[section].listID = priorityListsData[section].listID
        } else if(byTag) {
            tableViewData[section].sectionData = [String]()
            tableViewData[section].sectionData = tagListsData[section].sectionData
            tableViewData[section].listID = tagListsData[section].listID
        }
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
        print("didSelectRowAt: section = \(indexPath.section)")
        print("row = \(indexPath.row)")
        if indexPath.row == 0 {
            if tableViewData[indexPath.section].opened {
                tableViewData[indexPath.section].opened = false
                print("previously opened, closing..")
                let sections = IndexSet.init(integer: indexPath.section)
                tableView.reloadSections(sections, with: .none)
            } else {
                tableViewData[indexPath.section].opened = true
                print("previously closed, now openning..")
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
                destination.isNew = false
                ref.child("ListItem").child(destination.listID!).queryOrdered(byChild: "creationDays").observe(.value, with: { (snapshot) in
                    destination.goalData.removeAll()
                    if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                        for snap in snapshots {
                            if let itemInfo = snap.value as? [String: Any] {
                                let itemID = snap.key
                                destination.goalData.append(SingleListViewController.listCellData(opened: false, itemID: itemID, title: itemInfo["content"] as! String, isGoalFinished: itemInfo["isFinished"] as! Bool, subgoalID: [String](), sectionData: [String](), isSubgoalFinished: [Bool]()))
                            
                               // retrive subgoal info
                                self.ref.child("Subgoal").child(itemID).queryOrdered(byChild: "creationDays").observe(.value, with: { (snapshot) in
                                    print("retriving subgoal info in database...")
                                    if destination.goalData.count > 0 {
                                    destination.goalData[destination.goalData.count - 1].subgoalID.removeAll()
                                    destination.goalData[destination.goalData.count - 1].isSubgoalFinished.removeAll()
                                    destination.goalData[destination.goalData.count - 1].sectionData.removeAll()
                                    }
                                    
                                    if let subsnapshots = snapshot.children.allObjects as? [DataSnapshot] {
                                        for subsnap in subsnapshots {
                                            if let subItemInfo = subsnap.value as?[String: Any] {
                                                destination.goalData[destination.goalData.count - 1].subgoalID.append(subsnap.key)
                                               
                                                destination.goalData[destination.goalData.count - 1].sectionData.append(subItemInfo["content"] as! String)
                                                print("has found subgoal: \(subItemInfo["content"] as! String)")
                                                destination.goalData[destination.goalData.count - 1].isSubgoalFinished.append(subItemInfo["isFinished"] as! Bool)
                                                
                                            }
                                        }
                                    } // end subgoal info retrival
                                    
                                })
                            } // if itemInfo as [String: Any]
                        } // end list item info retrival
                    }
                    
                    destination.tableView.reloadData()
                    self.ref.child("List").child(destination.listID!).child("userID").observeSingleEvent(of: .value, with: { (snapshot) in
                        if let creatorID = snapshot.value as? String {
                            if creatorID == self.user.userID {
                                destination.isEditable = true
                            } else {
                                destination.isEditable = false
                            }
                        }
                    })
                })
            }
        }
    }
    
    // MARK: database operations
    func getTableViewDataFromDatabase() {
        // section data (listTitle) & listID
        if(byPriority){
            print("going to fetch lists from database")
            let priorityListRef = ref.child("PriorityList").child(user.userID)
            for index in priorityListsData.indices {
                print("index = \(index)")
                let level = priorityListsData[index].title
                print(level)
                priorityListRef.child(level).observeSingleEvent(of: .value, with: { (snapshot) in
                    print("observing...")
                    if(!snapshot.exists()) {
                        print("snapshot does not exist")
                        
                        // should have no lists under that priority level
                        print("priorityListsData[index].listID.count = \(self.priorityListsData[index].listID.count)")
                        self.priorityListsData[index].sectionData = [String]()
                        self.tableView.reloadData()
                    } else {
                        print("snapshot does exist")
                        self.priorityListsData[index].listID = [String]()
                        if let ids = snapshot.children.allObjects as? [DataSnapshot] {
                            for id in ids {
                                self.priorityListsData[index].listID.append(id.value as! String)
                            }
                            print("priorityListsData[index].listID.count = \(self.priorityListsData[index].listID.count)")
                            self.priorityListsData[index].sectionData = [String]()
                            for listid in self.priorityListsData[index].listID {
                                self.ref.child("List").child(listid).observeSingleEvent(of: .value, with: { (snapshot) in
                                    if let tempData = snapshot.value as? [String: Any] {
                                        let listName = tempData["listTitle"] as? String
                                        self.priorityListsData[index].sectionData.append(listName!)
                                    }
                                })
                            }
                        }
                    }
                })
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
        tableView.reloadData()
    }
}


