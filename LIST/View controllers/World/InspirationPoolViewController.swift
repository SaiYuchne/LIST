//
//  InspirationPoolViewController.swift
//  LIST
//
//  Created by 蔡雨倩 on 07/07/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import UIKit
import FirebaseDatabase

class InspirationPoolViewController: UIViewController {

    let ref = Database.database().reference()
    let user = LISTUser()
    
    struct cellData {
        var itemID = String()
        var content = String()
        var listID = String()
        var tags = [String]()
    }
    
    var bigWishPool = [cellData]()
    
    var listID: String? {
        didSet {
            seeListButton.isHidden = false
            likeListButton.isHidden = false
        }
    }
    var listCount: Int?
    var wish = "Tap to view more wishes!" {
        didSet {
            let labelFontSize = self.view.bounds.size.height * 0.05
            wishLabel.attributedText = createAttributedString(wish, fontSize: labelFontSize, isCentered: true)
        }
    }
    var tag = "#LIST" {
        didSet {
            let labelFontSize = self.view.bounds.size.height * 0.05
            tagLabel.attributedText = createAttributedString(tag, fontSize: labelFontSize * 0.7, isCentered: false)
        }
    }
    var isTagSpecific = false
    
    @IBOutlet weak var background: RoundRecView!{
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(randomWishTapped(_: )))
            background.addGestureRecognizer(tap)
        }
    }
    
    @IBOutlet weak var tagLabel: UILabel!
    
    @IBOutlet weak var wishLabel: UILabel!
    
    @IBOutlet weak var seeListButton: UIButton!
    @IBOutlet weak var likeListButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let labelFontSize = self.view.bounds.size.height * 0.05
        tagLabel.attributedText = createAttributedString(tag, fontSize: labelFontSize * 0.7, isCentered: false)
        wishLabel.attributedText = createAttributedString(wish, fontSize: labelFontSize, isCentered: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let labelFontSize = self.view.bounds.size.height * 0.05
        tagLabel.attributedText = createAttributedString(tag, fontSize: labelFontSize * 0.7, isCentered: false)
        wishLabel.attributedText = createAttributedString(wish, fontSize: labelFontSize, isCentered: true)
        
        if listID == nil {
            seeListButton.isHidden = true
            likeListButton.isHidden = true
        } else {
            seeListButton.isHidden = false
            likeListButton.isHidden = false
        }
    }
    
    @objc func randomWishTapped(_ recognizer: UITapGestureRecognizer){
        switch recognizer.state {
        case .ended:
            UIView.transition(with: background, duration: 0.6, options: .transitionFlipFromLeft, animations: {
                self.pickARandomWish()
                self.tagLabel.text = self.tag
                self.wishLabel.text = self.wish
                self.view.setNeedsLayout()
            })
        default:
            break
        }
    }
    
    @IBAction func likeListTapped(_ sender: UIButton) {
        if listID != nil {
            print("listID = \(listID!)")
            
            // add this list to the user's favourite lists
            ref.child("List").child(listID!).observeSingleEvent(of: .value, with: { (snapshot) in
                let listInfo = snapshot.value as! [String: Any]
                let creatorID = listInfo["userID"] as! String
                if creatorID == self.user.userID {
                    self.presentIsSelfAlert()
                } else {
                    if(!self.alreadyFaved(listID: self.listID!)) {
                        let listName = listInfo["listTitle"] as! String
                        self.ref.child("FavouriteList").child(self.user.userID).child(self.listID!).setValue(listName)
                        self.presentAddFavListSuccess()
                    } else {
                        self.presentAlreadyFavedAlert()
                    }
                }
            })
        }
    }
    
    func alreadyFaved(listID: String) -> Bool {
        var already = false
        ref.child("FavouriteList").child(user.userID).child(listID).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                already = true
            }
        }
        return already
    }
    
    func presentAddFavListSuccess() {
        let alert = UIAlertController(title: "Successful", message: "Just added this list to your favourite list!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func presentIsSelfAlert() {
        let alert = UIAlertController(title: "Sorry", message: "This list was created by you.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func presentAlreadyFavedAlert() {
        let alert = UIAlertController(title: "Sorry", message: "You have already faved this list.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func seeListTapped(_ sender: UIButton) {
        if listID != nil {
            self.performSegue(withIdentifier: "goToOriginalList", sender: self)
        }
    }
    
    // MARK: the randomization of choosing random wishes: produce as needed
    func pickARandomWish() {
        if(isTagSpecific){
            var listCount = 0
            ref.child("Tag").child("tags").child(tag).observeSingleEvent(of: .value) { (snapshot) in
                listCount = snapshot.value as! Int
            }
            
            let randomIndex = Int(arc4random_uniform(UInt32(listCount))) + 1
            ref.child("Tag").child("tags").child(tag).child("listIDs").observeSingleEvent(of: .value) { (snapshot) in
                if let listIDs = snapshot.children.allObjects as? [String] {
                    var count = 0
                    for listID in listIDs {
                        if count == randomIndex {
                            self.listID = listID
                            // randomly pick a wish
                            self.ref.child("ListItem").child(listID).observeSingleEvent(of: .value, with: { (snapshot) in
                                let wishCount = snapshot.childrenCount
                                let randomWishIndex = Int(arc4random_uniform(UInt32(wishCount))) + 1
                                if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                                    let wishID = snapshots[randomWishIndex].key
                                    self.ref.child("ListItem").child(self.listID!).child(wishID).child("content").observeSingleEvent(of: .value, with: { (snapshot) in
                                        self.wish = snapshot.value as! String
                                    })
                                }
                            })
                        }
                    }
                    count = count + 1
                }
            }
        } else { // non tag specific
            let randomWishIndex = Int(arc4random_uniform(UInt32(bigWishPool.count)))
            let randomTagIndex = Int(arc4random_uniform(UInt32(bigWishPool[randomWishIndex].tags.count)))
            self.tag = "#\(bigWishPool[randomWishIndex].tags[randomTagIndex])"
            self.listID = bigWishPool[randomWishIndex].listID
            self.wish = bigWishPool[randomWishIndex].content
        }
    }
    
    private func createAttributedString(_ string: String, fontSize: CGFloat, isCentered: Bool) -> NSAttributedString {
        var font = UIFont.preferredFont(forTextStyle: .body).withSize(fontSize)
        font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
        let paragraphStyle = NSMutableParagraphStyle()
        if isCentered {
            paragraphStyle.alignment = .center
        } else {
            paragraphStyle.alignment = .left
        }
        return NSAttributedString(string: string, attributes: [.paragraphStyle:paragraphStyle,.font:font])
    }
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToOriginalList" {
            if let destination = segue.destination as? SingleFavouriteListViewController {
                destination.listID = listID!
                ref.child("List").child(listID!).child("listTitle").observeSingleEvent(of: .value, with: { (snapshot) in
                    destination.listName = snapshot.value as! String
                })
                ref.child("ListItem").child(listID!).queryOrdered(byChild: "creationDays").observe(.value, with: { (snapshot) in
                    destination.goalData.removeAll()
                    if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                        for snap in snapshots {
                            if let itemInfo = snap.value as? [String: Any] {
                                let itemID = snap.key
                                destination.goalData.append(SingleFavouriteListViewController.cellData(opened: false, itemID: itemID, title: itemInfo["content"] as! String, subgoalID: [String](), sectionData: [String]()))
                                
                                // retrive subgoal info
                                self.ref.child("Subgoal").child(itemID).queryOrdered(byChild: "creationDays").observe(.value, with: { (snapshot) in
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
