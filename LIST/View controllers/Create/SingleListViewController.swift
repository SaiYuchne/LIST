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
    private var isEditable: Bool {
        let creatorID = ref.child("List").child(listID!).value(forKey: "userID") as! String
        if creatorID == user.userID {
            return true
        } else {
            return false
        }
    }
    var isNew: Bool?
    
    struct cellData{
        var opened = Bool()
        
        var itemID = String()
        var title = String()
        var isGoalFinished = Bool()
        
        var subgoalID = [String]()
        var sectionData = [String]()
        var isSubgoalFinished = [Bool]()
    }

    var goalData = [cellData]()
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var listNameLabel: UILabel!
    var listName: String?
    var listID: String?
    var selectedWishIndex: Array<Any>.Index?
    
    private var totalNumOfItems = 0
    private var numOfCompletedItems = 0 {
        didSet {
            if numOfCompletedItems == totalNumOfItems {
                completeWholeList()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        configureListNameLabel(listNameLabel)
        
        // get the tableViewData from the database if the list is not newly created
        if !isNew! {
            getTableViewDataFromDatabase()
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
        print("tableView.numberOfSections = \(tableView.numberOfSections)")
        if indexPath.section+1 != tableView.numberOfSections{
            if indexPath.row == 0 {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "listItemCell") as? ListItemTableViewCell else {return UITableViewCell()}
                print("indexPath.section is \(indexPath.section) \n indexPath.row is \(indexPath.row)")
                cell.goalLabel.text = goalData[indexPath.section].title
                if(goalData[indexPath.section].isGoalFinished){
                    cell.completeButton.setTitle("✔️", for: .normal)
                    cell.listID = listID
                    cell.itemID = goalData[indexPath.section].itemID
                    numOfCompletedItems += 1
                }
                totalNumOfItems += 1
                return cell
            } else {
                let indexData = indexPath.row - 1
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "subgoalCell") as? SubgoalTableViewCell else {return UITableViewCell()}
                cell.subgoalLabel.text = goalData[indexPath.section].sectionData[indexData]
                if(goalData[indexPath.section].isSubgoalFinished[indexData]){
                    cell.completeGoalButton.setTitle("✔️", for: .normal)
                    cell.itemID = goalData[indexPath.section].itemID
                    cell.subgoalID = goalData[indexPath.section].subgoalID[indexPath.row]
                    numOfCompletedItems += 1
                }
                totalNumOfItems += 1
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
                self.goalData.append(cellData(opened: false, itemID: key,  title: wish, isGoalFinished: false, subgoalID: [], sectionData: [], isSubgoalFinished: []))
                // add the wish in the database
                self.addWishInDatabase(key: key, wish: wish)
                self.totalNumOfItems += 1
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
                let goal: String
                var wishIndex: Array<Any>.Index?
                if let subgoal = alert.textFields?[0].text{
                    if let superView = sender.superview?.superview as? ListItemTableViewCell {
                        goal = superView.goalLabel.text!
                        for index in self.goalData.indices {
                            if self.goalData[index].title == goal {
                               
                               wishIndex = index
                                self.goalData[index].sectionData.append(subgoal)
                                self.goalData[index].isSubgoalFinished.append(false)
                            }
                        }
                    }
                    self.addSubgoalInDatabase(wishIndex: wishIndex!, subgoal: subgoal)
                    self.totalNumOfItems += 1
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
                    let yes = UIAlertAction(title: "Yes", style: .default) { (_) in
                        self.totalNumOfItems -= 1
                        // delete data in the database
                        self.deleteWishFromDatabase(itemID: self.goalData[indexPath.section].itemID)
                        self.totalNumOfItems -= self.goalData[indexPath.section].sectionData.count
                        self.goalData.remove(at: indexPath.section)
                        let indexSet = IndexSet(arrayLiteral: indexPath.section)
                        self.tableView.deleteSections(indexSet, with: .fade)
                    }
                    alert.addAction(no)
                    alert.addAction(yes)
                    present(alert, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: "Warning", message: "Delete this subgoal?", preferredStyle: .alert)
                    let no = UIAlertAction(title: "No", style: .cancel, handler: nil)
                    let yes = UIAlertAction(title: "Yes", style: .default) { (_) in
                        self.totalNumOfItems -= 1
                        // delete data in the database
                        self.goalData[indexPath.section].sectionData.remove(at: indexPath.row)
                        // the following code may need modification
                        self.tableView.deleteRows(at: [indexPath], with: .fade)
                        self.deleteSubgoalFromDatabase(itemID: self.goalData[indexPath.section].itemID, subgoalID: self.goalData[indexPath.section].subgoalID[indexPath.row])
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
                    }
                }
            }
        } else if segue.identifier == "goToListSettings" {
            if isEditable{
                if let destination = segue.destination as? ListSettingsTableViewController {
                    if sender is UIButton {
                        if let _ = (sender as! UIButton).superview?.superview as? ToolTableViewCell {
                            destination.listID = listID
                        }
                    }
                }
            } else {
                let alert = UIAlertController(title: "No access", message: "Sorry, only the creator can change the list settings", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            }
        }
    }
    
    // MARK: complete wish/subgoal button tapped
    @IBAction func completeGoalButtonTapped(_ sender: UIButton) {
        if sender.titleLabel?.text == "🔲" {
            sender.setTitle("✔️", for: .normal)
            numOfCompletedItems += 1
        } else {
            sender.setTitle("🔲", for: .normal)
            numOfCompletedItems -= 1
        }
    }
    
    @IBAction func completeSubgoalButtonTapped(_ sender: UIButton) {
        if sender.titleLabel?.text == "⚪️" {
            sender.setTitle("✔️", for: .normal)
            numOfCompletedItems += 1
        } else {
            sender.setTitle("⚪️", for: .normal)
            numOfCompletedItems -= 1
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
                    
                    self.goalData.append(cellData(opened: false, itemID: key, title: tempData["content"] as! String, isGoalFinished: tempData["isFinished"] as! Bool, subgoalID: [],  sectionData: [],  isSubgoalFinished: []))
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
        
        let defaultListItemInfo = ["content": wish, "isFinished": false] as [String : Any?]
        
        // update ListItem
        listItemRef.child(key).setValue(defaultListItemInfo)
        // update Subgoal
        ref.child("Subgoal").child(key)
    }
    
    func addSubgoalInDatabase(wishIndex: Array<Any>.Index, subgoal: String){
        let subgoalRef = ref.child("Subgoal").child(goalData[wishIndex].itemID)
        
        let subgoalID = subgoalRef.childByAutoId().key
        let subgoalInfo = ["content": subgoal, "isFinished": false] as [String : Any?]
        subgoalRef.child(subgoalID).setValue(subgoalInfo)
        goalData[wishIndex].subgoalID.append(subgoalID)
    }
    
    // delete wish including all its subgoals from database
    func deleteWishFromDatabase(itemID: String){
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
        let alert = UIAlertController(title: "Congratulations!", message: "You have completed all goals in this list!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Thanks", style: .default, handler: nil))
        
        ref.child("List").child(listID!).child("isFinished").setValue(true)
        let archiveRef = ref.child("Archive").child(listID!)
        ref.child("List").child(listID!).observeSingleEvent(of: .value) { (snapshot) in
            let tempData = snapshot.value as? Dictionary<String, Any>
            let listTitle = tempData!["listTitle"] as? String
            let userID = tempData!["userID"] as? String
            let privacy = tempData!["privacy"] as? String
            let priority = tempData!["priority"] as? String
            let creationDate = tempData!["creationDate"] as? String
            let deadline = tempData!["deadline"] as? String
            let tag = tempData!["userID"] as? [String]
            let collaborator = tempData!["collaborator"] as? [String]
            let completionDate = Date().toString(dateFormat: "dd-MM-yyyy")
            let archiveInfo = ["listTitle": listTitle, "userID": userID, "privacy": privacy, "priority": priority, "creationDate": creationDate, "deadline": deadline, "tag": tag, "collaborator": collaborator, "cimpletionDate": completionDate] as [String : Any?]
            archiveRef.setValue(archiveInfo)
        }
        ref.child("List").child(listID!).removeValue()
        
        // update the count of completed lists
        if let count = ref.child("Archive").child("count").value(forKey: user.userID) as? Int {
            ref.child("Archive").child("count").child(user.userID).setValue(count+1)
        } else {
            ref.child("Archive").child("count").child(user.userID).setValue(1)
        }
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
