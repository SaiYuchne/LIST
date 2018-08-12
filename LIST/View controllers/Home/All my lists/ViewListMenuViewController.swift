//
//  ViewListMenuViewController.swift
//  LIST
//
//  Created by 蔡雨倩 on 11/06/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ViewListMenuViewController: UIViewController {
    
    let user = LISTUser()
    let ref = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        print("Check: should perform segue:")
        var shouldPerform = true
        
        if identifier == "viewByPriority" {
            ref.child("PriorityList").child(user.userID).observeSingleEvent(of: .value, with: { (snapshot) in
                if !snapshot.exists() {
                    print("snapshot does not exist")
                    shouldPerform = false
                    let alert = UIAlertController(title: "Sorry", message: "You haven't created any list. You can go to create one and then come back.", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                        self.navigationController?.popViewController(animated: true)
                    })
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                }
            })
        } else if identifier == "viewByDeadline" {
            print("viewByDeadline")
            ref.child("DeadlineList").child(user.userID).observeSingleEvent(of: .value, with: { (snapshot) in
                if !snapshot.exists() {
                    print("snapshot does not exist")
                    shouldPerform = false
                    let alert = UIAlertController(title: "Sorry", message: "You haven't created any list. You can go to create one and then come back.", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                        self.navigationController?.popViewController(animated: true)
                    })
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                }
            })
        } else {
            print("viewByTag")
            ref.child("TagList").child(user.userID).observeSingleEvent(of: .value, with: { (snapshot) in
                if !snapshot.exists() {
                    print("snapshot does not exist")
                    shouldPerform = false
                    let alert = UIAlertController(title: "Sorry", message: "You haven't added any tags to your lists or haven't created a list before. You may view your lists by priority level or deadline and then add some tags to your lists.", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                        self.navigationController?.popViewController(animated: true)
                    })
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                }
            })
        }
        
        return shouldPerform
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewByPriority" {
            if let destination = segue.destination as? ViewListViewController {
                destination.byPriority = true
                destination.byDeadline = false
                destination.byTag = false
                // pass data
                let priorityListRef = ref.child("PriorityList").child(user.userID)
                for index in destination.priorityListsData.indices {
                    let level = destination.priorityListsData[index].title
                    priorityListRef.child(level).observe(.value, with: { (snapshot) in
                            if(!snapshot.exists()) {
                            
                                // should have no lists under that priority level
                                destination.priorityListsData[index].sectionData = [String]()
//                                destination.tableView.reloadData()
                            } else {
                                destination.priorityListsData[index].listID = [String]()
                                if let ids = snapshot.children.allObjects as? [DataSnapshot] {
                                    for id in ids {
                                    destination.priorityListsData[index].listID.append(id.value as! String)
                                    }
                                    destination.priorityListsData[index].sectionData = [String]()
                                    for listid in destination.priorityListsData[index].listID {
                                        self.ref.child("List").child(listid).observeSingleEvent(of: .value, with: { (snapshot) in
                                                if let tempData = snapshot.value as? [String: Any] {
                                                let listName = tempData["listTitle"] as? String
                                            destination.priorityListsData[index].sectionData.append(listName!)
                                                }
                                            })
                                    } // end for loop
                            } // end else
                        }
                        destination.tableViewData = destination.priorityListsData
                        destination.tableView.reloadData()
                    }) // end observing
                }
            }
        } else if segue.identifier == "viewByDeadline" {
            if let destination = segue.destination as? ViewListViewController {
                destination.byDeadline = true
                destination.byPriority = false
                destination.byTag = false
                // pass data
                // It is assumed that the remaining days will be in increasing order
                let DeadlineListRef = ref.child("DeadlineList").child(user.userID)
                DeadlineListRef.observe(.value, with: {(snapshot) in
                    destination.tableViewData.removeAll()
                    if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                        for snap in snapshots {
                            let remainingDays = snap.key
                            var newCell = ViewListViewController.cellData(opened: false, title: remainingDays, sectionData: [String](), listID: [String]())
                            if let subSnapshots = snap.children.allObjects as? [DataSnapshot] {
                                for subSnap in subSnapshots {
                                    newCell.listID.append(subSnap.key)
                                    let listInfo = subSnap.value as! [String: String]
                                    newCell.sectionData.append(listInfo["listTitle"]!)
                                    newCell.title = listInfo["deadline"]!
                                }
                                destination.tableViewData.append(newCell)
                            }
                        }
                    }
                    destination.tableView.reloadData()
                })
            }
        } else {
            if let destination = segue.destination as? ViewListViewController {
                destination.byTag = true
                destination.byPriority = false
                destination.byDeadline = false
                // pass data
                let TagListRef = ref.child("TagList").child(user.userID)
                for index in destination.tagListsData.indices {
                    let tag = destination.tagListsData[index].title
                    TagListRef.child(tag).observe(.value, with: { (snapshot) in
                        if(!snapshot.exists()) {
                            
                            // should have no lists under that tag
                            destination.tagListsData[index].sectionData = [String]()
                            destination.tableView.reloadData()
                        } else {
                            destination.tagListsData[index].listID = [String]()
                            destination.tagListsData[index].sectionData = [String]()
                            if let listTitles = snapshot.children.allObjects as? [DataSnapshot] {
                                for listTitle in listTitles {
                                    destination.tagListsData[index].listID.append(listTitle.key)
                                    destination.tagListsData[index].sectionData.append(listTitle.value as! String)
                                    
                                }
                            } // end else
                        }
                        destination.tableViewData = destination.tagListsData
                        destination.tableView.reloadData()
                    }) // end observing
                } // end observing
            }
        }
    }

}
