//
//  FriendListViewController.swift
//  LIST
//
//  Created by 蔡雨倩 on 27/07/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import UIKit
import FirebaseDatabase

class FriendListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let user = LISTUser()
    let ref = Database.database().reference()
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var friendNameLabel: UILabel!
    
    var listIDs = [String]()
    var listTitles = [String]()
    var chosenRow: Int?
    var friendName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        friendNameLabel.attributedText = centeredAttributedString("Open lists", fontSize: friendNameLabel.bounds.size.height * 0.6)
    }

    private func centeredAttributedString(_ string: String, fontSize: CGFloat) -> NSAttributedString {
        var font = UIFont.preferredFont(forTextStyle: .body).withSize(fontSize)
        font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        return NSAttributedString(string: string, attributes: [.paragraphStyle:paragraphStyle,.font:font])
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listIDs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "friendListCell") else {
            return UITableViewCell()}
        cell.textLabel?.text = listTitles[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosenRow = indexPath.row
        performSegue(withIdentifier: "goToAFriendList", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToAFriendList" {
            if let destination = segue.destination as? SingleFavouriteListViewController {
                destination.listName = listTitles[chosenRow!]
                destination.listID = listIDs[chosenRow!]
                ref.child("ListItem").child(listIDs[chosenRow!]).queryOrdered(byChild: "creationDays").observeSingleEvent(of: .value, with: { (snapshot) in
                    destination.goalData.removeAll()
                    if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                        for snap in snapshots {
                            if let itemInfo = snap.value as? [String: Any] {
                                let itemID = snap.key
                                destination.goalData.append(SingleFavouriteListViewController.cellData(opened: false, itemID: itemID, title: itemInfo["content"] as! String, subgoalID: [String](), sectionData: [String]()))
                                
                                // retrive subgoal info
                                self.ref.child("Subgoal").child(itemID).queryOrdered(byChild: "creationDays").observeSingleEvent(of: .value, with: { (snapshot) in
                                    if destination.goalData.count > 0 {
                                        destination.goalData[destination.goalData.count - 1].subgoalID.removeAll()
                                        destination.goalData[destination.goalData.count - 1].sectionData.removeAll()
                                    }
                                    
                                    if let subsnapshots = snapshot.children.allObjects as? [DataSnapshot] {
                                        for subsnap in subsnapshots {
                                            if let subItemInfo = subsnap.value as?[String: Any] {
                                                destination.goalData[destination.goalData.count - 1].subgoalID.append(subsnap.key)
                                                
                                                destination.goalData[destination.goalData.count - 1].sectionData.append(subItemInfo["content"] as! String)
                                            }
                                        }
                                    } // end subgoal info retrival
                                    
                                })
                            } // if itemInfo as [String: Any]
                        } // end list item info retrival
                    }
                    
                    destination.tableView.reloadData()
                })
            }
        }
    }
}
