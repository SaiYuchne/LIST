//
//  SingleListViewController.swift
//  LIST
//
//  Created by 蔡雨倩 on 08/06/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import UIKit
import FirebaseDatabase

class SingleListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let ref = Database.database().reference()
    private lazy var user = LISTUser()
    // MARK: to do: should be decided by segue preparation
    var isEditable: Bool?
    
    var isNew: Bool?
    private var totalNumOfItems: Int {
        var count = 0
        count += goalData.count
        for listData in goalData {
            count += listData.subgoalID.count
        }
        
        print("counting totalNumOfItems: \(count)")
        return count
    }

    var numOfCompletedItems = 0
    
    struct listCellData {
        var opened = Bool()
        
        var itemID = String()
        var title = String()
        var isGoalFinished = Bool()
        
        var subgoalID = [String]()
        var sectionData = [String]()
        var isSubgoalFinished = [Bool]()
    }
    
    var goalData = [listCellData]()
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var listNameLabel: UILabel!
    var listName: String?
    var listID: String?
    var selectedWishIndex: Array<Any>.Index?
    
//    private var numOfCompletedItems: Int {
//        var count = 1
//        for listData in goalData {
//            if listData.isGoalFinished {
//                print(listData.title)
//                count += 1
//            }
//            for isFinished in listData.isSubgoalFinished {
//                if isFinished {
//                    count += 1
//                }
//            }
//        }
//        
//        print("counting numOfCompletedItems: \(count)")
//        return count
//    }
    
    override func viewDidLoad() {
        print("listID is \(listID!)")
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        configureListNameLabel(listNameLabel)
        
        // get the tableViewData from the database if the list is not newly created
//        if !isNew! {
//            getTableViewDataFromDatabase()
//        }

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        numOfCompletedItems = 0
        var itemIDs = [String]()
        
        ref.child("ListItem").child(listID!).queryOrdered(byChild: "isFinished").queryEqual(toValue: true).observeSingleEvent(of: .value) { (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                self.numOfCompletedItems += snapshots.count
                for snap in snapshots {
                    itemIDs.append(snap.key)
                }
            }
            
            for id in itemIDs {
                self.ref.child("Subgoal").child(id).queryOrdered(byChild: "isFinished").queryEqual(toValue: true).observeSingleEvent(of: .value, with: { (snapshot) in
                    if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                        self.numOfCompletedItems += snapshots.count
                    }
                })
            }
            print("numOfCompletedItems = \(self.numOfCompletedItems)")
        }
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
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "listItemCell") as? ListItemTableViewCell else {return UITableViewCell()}
                cell.goalLabel.text = goalData[indexPath.section].title
                cell.listID = listID
                cell.itemID = goalData[indexPath.section].itemID
                if(goalData[indexPath.section].isGoalFinished){
                    cell.completeButton.setTitle("✔️", for: .normal)
                }
                return cell
            } else {
                print("row is \(indexPath.row)")
                let indexData = indexPath.row - 1
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "subgoalCell") as? SubgoalTableViewCell else {return UITableViewCell()}
                print("configure a subgoalCell")
                cell.subgoalLabel.text = goalData[indexPath.section].sectionData[indexData]
                print("the subgoal is \(goalData[indexPath.section].sectionData[indexData])")
                cell.itemID = goalData[indexPath.section].itemID
                print("the itemID is \(goalData[indexPath.section].itemID)")
                cell.subgoalID = goalData[indexPath.section].subgoalID[indexData]
                print("the subgoalID is \(goalData[indexPath.section].subgoalID[indexData])")
                if(goalData[indexPath.section].isSubgoalFinished[indexData]){
                    cell.completeGoalButton.setTitle("✔️", for: .normal)
                }
                return cell
            }
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "toolCell", for: indexPath)
        return cell
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Add a wish", message: "What wish do you have?", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Type your wish for this list here"
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let add = UIAlertAction(title: "Add", style: .default) { (_) in
            if let wish = alert.textFields?[0].text{
                let key = self.ref.child("ListItem").child(self.listID!).child("items").childByAutoId().key
                self.goalData.append(listCellData(opened: false, itemID: key,  title: wish, isGoalFinished: false, subgoalID: [], sectionData: [], isSubgoalFinished: []))
                // add the wish in the database
                self.addWishInDatabase(key: key, wish: wish)
                print("totalNumOfItems will be added 1")
                
                self.tableView.reloadData()
            }
        }
        alert.addAction(cancel)
        alert.addAction(add)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func goalSettingsTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "What do you want to do?", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Add a subgoal", style: .default, handler: { (action) in
            let alert = UIAlertController(title: "Add a subgoal", message: nil, preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.placeholder = "Type your subgoal for this wish here"
            }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let add = UIAlertAction(title: "Add", style: .default) { (_) in
                //add a subgoal in the database
                let goalID: String
                var wishIndex: Array<Any>.Index?
                if let subgoal = alert.textFields?[0].text{
                    if let superView = sender.superview?.superview as? ListItemTableViewCell {
                        goalID = superView.itemID!
                        for index in self.goalData.indices {
                            if self.goalData[index].itemID == goalID {
                               
                               wishIndex = index
                                self.goalData[index].sectionData.append(subgoal)
                                self.goalData[index].isSubgoalFinished.append(false)
                            }
                        }
                    }
                    self.addSubgoalInDatabase(wishIndex: wishIndex!, subgoal: subgoal)
                    self.goalData[wishIndex!].opened = true
                    let sections = IndexSet.init(integer: wishIndex!)
                    self.tableView.reloadSections(sections, with: .none)
                }
            }
            alert.addAction(cancel)
            alert.addAction(add)
            self.present(alert, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "document progress", style: .default, handler: { (action) in
            let goal: String
                if let superView = sender.superview?.superview as? ListItemTableViewCell {
                    goal = superView.goalLabel.text!
                    for index in self.goalData.indices {
                        if self.goalData[index].title == goal {
                            self.selectedWishIndex = index
                        }
                    }
                }
            
            self.performSegue(withIdentifier: "goToGoalSettings", sender: sender)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        tableView.reloadData()
    }
    
    // MARK: delete list items
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            if indexPath.section != tableView.numberOfSections{
                if indexPath.row == 0 {
                    let alert = UIAlertController(title: "Warning", message: "Delete this wish?", preferredStyle: .alert)
                    let no = UIAlertAction(title: "No", style: .cancel, handler: nil)
                    let yes = UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                        // delete data in the database
                        self.deleteWishFromDatabase(itemID: self.goalData[indexPath.section].itemID)
                        // update numOfCompletedItems
                        print("updating numOfCompletedItems")
                        print("there are \(self.goalData[indexPath.section].isSubgoalFinished.count) subgoals in total")
                        for index in self.goalData[indexPath.section].sectionData.indices {
                            print("subgoal\(index): \(self.goalData[indexPath.section].sectionData[index]) finished: \(self.goalData[indexPath.section].isSubgoalFinished[index])")
                            if self.goalData[indexPath.section].isSubgoalFinished[index] {
                                print("numOfCompletedItems decrease one")
                                self.numOfCompletedItems -= 1
                            }
                        }
                        if self.goalData[indexPath.section].isGoalFinished {
                            print("the goal itself is finished, hence decrease one")
                            self.numOfCompletedItems -= 1
                        }
                        
                        self.goalData.remove(at: indexPath.section)
                        let indexSet = IndexSet(arrayLiteral: indexPath.section)
                        self.tableView.deleteSections(indexSet, with: .fade)
                        if self.totalNumOfItems == self.numOfCompletedItems, self.totalNumOfItems != 0 {
                            self.completeWholeList()
                        }
                    })
                    alert.addAction(no)
                    alert.addAction(yes)
                    present(alert, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: "Warning", message: "Delete this subgoal?", preferredStyle: .alert)
                    let no = UIAlertAction(title: "No", style: .cancel, handler: nil)
                    let yes = UIAlertAction(title: "Yes", style: .default) { (_) in
                        // delete data in the database
                        self.deleteSubgoalFromDatabase(itemID: self.goalData[indexPath.section].itemID, subgoalID: self.goalData[indexPath.section].subgoalID[indexPath.row - 1])
                        if self.goalData[indexPath.section].isSubgoalFinished[indexPath.row - 1] {
                            self.numOfCompletedItems -= 1
                        }
                        self.goalData[indexPath.section].sectionData.remove(at: indexPath.row - 1)
                        self.tableView.deleteRows(at: [indexPath], with: .fade)
                        if self.totalNumOfItems == self.numOfCompletedItems, self.totalNumOfItems != 0 {
                            self.completeWholeList()
                        }
                    }
                    alert.addAction(no)
                    alert.addAction(yes)
                    present(alert, animated: true, completion: nil)
                }
            }
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToGoalSettings" {
            if let destination = segue.destination as? ListItemViewController {
                if sender is UIButton {
                    if let superView = (sender as! UIButton).superview?.superview as? ListItemTableViewCell {
                        destination.itemName = superView.goalLabel.text
                        destination.itemID = self.goalData[selectedWishIndex!].itemID
                        destination.listID = listID!
                    }
                }
            }
        } else if segue.identifier == "goToListSettings" {
            if isEditable!{
                print("isEditable is true")
                if let destination = segue.destination as? ListSettingsTableViewController {
                    destination.listID = listID
                    ref.child("List").child(listID!).observeSingleEvent(of: .value, with: { (snapshot) in
                        // MARK: to do: tags and collaborators retrieval
                        if let listSettings = snapshot.value as? [String: Any] {
                            destination.settings = ["List name": listSettings["listTitle"] as! String, "Creation date": listSettings["creationDate"] as! String, "Deadline": listSettings["deadline"] as! String, "Priority level": listSettings["priority"] as! String, "Who can view this list": listSettings["privacy"] as! String, "Tags": nil, "Collaborators": nil, "Delete this list": nil]
                            destination.tableView.reloadData()
                        }
                    })
                    
                }
            } else {
                print("isEditable is false")
                let alert = UIAlertController(title: "No access", message: "Sorry, only the creator can change the list settings", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: complete wish/subgoal button tapped
    @IBAction func completeGoalButtonTapped(_ sender: UIButton) {
        if sender.titleLabel?.text == "🔲" {
            print("from vc: previously🔲")
            sender.setTitle("✔️", for: .normal)
            if isNew!, let superView = sender.superview?.superview as? ListItemTableViewCell {
                let goalID = superView.itemID!
                for index in self.goalData.indices {
                    if self.goalData[index].itemID == goalID {
                        
                        self.goalData[index].isGoalFinished = true
                    }
                }
            }
            self.numOfCompletedItems += 1
        } else {
            print("from vc: previously✔️")
            sender.setTitle("🔲", for: .normal)
            if isNew!, let superView = sender.superview?.superview as? ListItemTableViewCell {
                let goalID = superView.itemID!
                for index in self.goalData.indices {
                    if self.goalData[index].itemID == goalID {
                        
                        self.goalData[index].isGoalFinished = false
                    }
                }
            }
            self.numOfCompletedItems -= 1
        }
        if self.totalNumOfItems == self.numOfCompletedItems, self.totalNumOfItems != 0 {
            print("\(totalNumOfItems)")
            completeWholeList()
        }
    }
    
    @IBAction func completeSubgoalButtonTapped(_ sender: UIButton) {
        if sender.titleLabel?.text == "⚪️" {
            print("from vc")
            sender.setTitle("✔️", for: .normal)
            if isNew!, let superView = sender.superview?.superview as? SubgoalTableViewCell {
                let goalID = superView.itemID!
                let subgoalID = superView.subgoalID!
                for index in self.goalData.indices {
                    if self.goalData[index].itemID == goalID {
                        for subIndex in self.goalData[index].subgoalID.indices {
                            if self.goalData[index].subgoalID[subIndex] == subgoalID {
                                self.goalData[index].isSubgoalFinished[subIndex] = true
                            }
                        }
                    }
                }
            }
            self.numOfCompletedItems += 1
        } else {
            print("from vc")
            sender.setTitle("⚪️", for: .normal)
            if isNew!, let superView = sender.superview?.superview as? SubgoalTableViewCell {
                let goalID = superView.itemID!
                let subgoalID = superView.subgoalID!
                for index in self.goalData.indices {
                    if self.goalData[index].itemID == goalID {
                        for subIndex in self.goalData[index].subgoalID.indices {
                            if self.goalData[index].subgoalID[subIndex] == subgoalID {
                                self.goalData[index].isSubgoalFinished[subIndex] = false
                            }
                        }
                    }
                }
            }
            self.numOfCompletedItems -= 1
        }
        if self.totalNumOfItems == self.numOfCompletedItems, self.totalNumOfItems != 0 {
            print("\(totalNumOfItems)")
            self.completeWholeList()
        }
    }
    
    
    // MARK: database operations
    func getTableViewDataFromDatabase(){
        let listItemRef = ref.child("ListItem").child(listID!)
        
        let _ = listItemRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                for snap in snapshots{
                    var tempData = snap.value as! Dictionary<String, Any>
                    let key = snap.key
                    
                    self.goalData.append(listCellData(opened: false, itemID: key, title: tempData["content"] as! String, isGoalFinished: tempData["isFinished"] as! Bool, subgoalID: [],  sectionData: [],  isSubgoalFinished: []))
                    let _ = self.ref.child("Subgoal").child(key).observeSingleEvent(of: .value, with: { (snapshot) in
                        if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                            for snap in snapshots{
                                var tempData = snap.value as! Dictionary<String, Any>
                                self.goalData[self.goalData.count-1].subgoalID.append(snap.key)
                                self.goalData[self.goalData.count-1].sectionData.append(tempData["content"] as! String)
                                self.goalData[self.goalData.count-1].isSubgoalFinished.append(tempData["isFinished"] as! Bool)
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
    
    func addWishInDatabase(key: String, wish: String) {
        let listItemRef = ref.child("ListItem").child(listID!)
        
        let defaultListItemInfo = ["content": wish, "isFinished": false, "creationDays": Int(Date().timeIntervalSinceReferenceDate)] as [String : Any?]
        
        // update ListItem
        listItemRef.child(key).setValue(defaultListItemInfo)
        // update Subgoal
        ref.child("Subgoal").child(key)
    }
    
    func addSubgoalInDatabase(wishIndex: Array<Any>.Index, subgoal: String){
        let subgoalRef = ref.child("Subgoal").child(goalData[wishIndex].itemID)
        
        let subgoalID = subgoalRef.childByAutoId().key
        let subgoalInfo = ["content": subgoal, "isFinished": false, "creationDays": Int(Date().timeIntervalSinceReferenceDate)] as [String : Any?]
        subgoalRef.child(subgoalID).setValue(subgoalInfo)
        goalData[wishIndex].subgoalID.append(subgoalID)
        print("has added subgoal \(subgoal) in database")
    }
    
    // delete wish including all its subgoals from database
    func deleteWishFromDatabase(itemID: String){
        print("delete from database")
        let listItemRef = ref.child("ListItem").child(listID!)
        listItemRef.child(itemID).removeValue()
        
        let subgoalRef = ref.child("Subgoal").child(itemID)
        subgoalRef.removeValue()
    }
    
    func deleteSubgoalFromDatabase(itemID: String, subgoalID: String){
        let subgoalRef = ref.child("Subgoal").child(itemID)
        subgoalRef.child(subgoalID).removeValue()
    }
    
    func completeWholeList() {
        ref.child("List").child(listID!).child("isFinished").setValue(true)
        ref.child("List").child(listID!).child("collaborator").observeSingleEvent(of: .value) { (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                var participants = [String]()
                for snap in snapshots {
                    participants.append(snap.key)
                }
                self.ref.child("List").child(self.listID!).observeSingleEvent(of: .value, with: { (snapshot) in
                    if let tempData = snapshot.value as? [String: Any] {
                        if let creatorID = tempData["userID"] as? String {
                            participants.append(creatorID)
                        }
                        let priority = tempData["priority"] as! String
                        // remove list in PriorityList & DeadlineList
                        for person in participants {
                            self.ref.child("PriorityList").child(person).child(priority).child(self.listID!).removeValue()
                                    self.ref.child("DeadlineList").child(person).child(self.listID!).removeValue()
                        }
                        
                        self.ref.child("List").child(self.listID!).child("tag").observeSingleEvent(of: .value, with: { (snapshot) in
                            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                                for snap in snapshots {
                                    for person in participants {
                                        self.ref.child("TagList").child(person).child(snap.key).child(self.listID!).removeValue()
                                    }
                                }
                            }
                        })
                        
                    }
                    
                    // update archive
                    let archiveRef = self.ref.child("Archive")
                    for person in participants {
                        archiveRef.child(person).child(self.listID!).setValue(self.listID!)
                        
                        archiveRef.child("count").child(person).observeSingleEvent(of: .value) { (snapshot) in
                            if !snapshot.exists() {
                                self.ref.child("Archive").child("count").child(person).setValue(1)
                            } else {
                                self.ref.child("Archive").child("count").child(person).setValue((snapshot.value as! Int) + 1)
                            }
                        }
                    }
                    let completionDate = Date().toString(dateFormat: "dd-MM-yyyy")
                    self.ref.child("List").child(self.listID!).child("completionDate").setValue(completionDate)
                })
            }
        }
        
        let alert = UIAlertController(title: "Congratulations!", message: "You have completed all goals in this list!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Thanks!", style: .default, handler: { (action) in
            self.performSegue(withIdentifier: "afterCompleteList", sender: self)
        }))
        present(alert, animated: true, completion: nil)
    }
}

extension NSDictionary {
    var swiftDictionary: Dictionary<String, Any> {
        var swiftDictionary = Dictionary<String, Any>()
        
        for key : Any in self.allKeys {
            let stringKey = key as! String
            if let keyValue = self.value(forKey: stringKey){
                swiftDictionary[stringKey] = keyValue
            }
        }
        
        return swiftDictionary
    }
}
