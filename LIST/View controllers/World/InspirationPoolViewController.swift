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
    
    var listID: String?
    var wish: String?
    var tag: String?
    
    
    @IBOutlet weak var randomWish: RandomWishView! {
        didSet{
            let tap = UITapGestureRecognizer(target: self, action: #selector(randomWishTapped(_: )))
            randomWish.addGestureRecognizer(tap)
        }
    }
    
    @objc func randomWishTapped(_ recognizer: UITapGestureRecognizer){
        switch recognizer.state {
        case .ended:
            UIView.transition(with: randomWish, duration: 0.6, options: .transitionFlipFromLeft, animations: {
                self.pickARandomWish()
                self.randomWish.listID = self.listID!
                self.randomWish.listTag = self.tag!
                self.randomWish.wish = self.wish!
                self.randomWish.setNeedsLayout()
            })
        default:
            break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    // MARK: the randomization of choosing random wishes: produce as needed
    private func pickARandomWish() {
        var totalNumOfTags = 0
        ref.child("Tag").child("numOfTags").observeSingleEvent(of: .value) { (snapshot) in
            totalNumOfTags = snapshot.value as! Int
        }
        
        let randomIndex = Int(arc4random_uniform(UInt32(totalNumOfTags))) + 1
        ref.child("Tag").child("tags").observeSingleEvent(of: .value) { (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                var count = 0
                for snap in snapshots {
                    if count == randomIndex {
                        var tempData = snap.value as! Dictionary<String, Any>
                        self.tag = tempData["tagName"] as? String
                        // randomly pick a list
                        let listIDs = tempData["listIDs"] as! [String]
                        let listIDCount = listIDs.count
                        let randomIndex2 = Int(arc4random_uniform(UInt32(listIDCount))) + 1
                        self.listID = listIDs[randomIndex2]
                        // randomly pick a wish
                    self.ref.child("ListItem").child(self.listID!).observeSingleEvent(of: .value, with: { (snapshot) in
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
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToOriginalList" {
            if let destination = segue.destination as? SingleFavouriteListViewController {
                let listID = randomWish.listID
                var listTitle: String?
                destination.listID = listID
                ref.child("List").child(listID!).child("listTitle").observeSingleEvent(of: .value, with: { (snapshot) in
                    listTitle = snapshot.value as? String
                })
                destination.listName = listTitle
            }
        }
    }
}
