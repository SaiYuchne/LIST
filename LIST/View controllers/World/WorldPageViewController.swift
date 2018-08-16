//
//  WorldPageViewController.swift
//  LIST
//
//  Created by 蔡雨倩 on 07/07/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import UIKit
import FirebaseDatabase

class WorldPageViewController: UIViewController {

    let ref = Database.database().reference()
    private var user = LISTUser()
    
    @IBOutlet weak var inspirationPoolExtractView: InspirationPoolExtractView!
    
    var trendingTags = [String]()
    var bigWishPool = [InspirationPoolViewController.cellData]()
    
    @IBOutlet weak var firstTagLabel: UILabel!
    @IBOutlet weak var secondTagLabel: UILabel!
    @IBOutlet weak var thirdTagLabel: UILabel!
    @IBOutlet weak var fourthTagLabel: UILabel!
    @IBOutlet weak var fifthTagLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getDataFromDatabase()
    }
    
    @IBOutlet weak var searchTagView: RoundRecView!{
        didSet{
            let tap = UITapGestureRecognizer(target: self, action: #selector(searchTagViewTapped(_: )))
            searchTagView.addGestureRecognizer(tap)
        }
    }
    
    @IBAction func inspirationPoolTapped(_ sender: UIButton) {
        ref.child("InspirationPool").observeSingleEvent(of: .value, with: { (snapshot) in
            print("mark 1")
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                print("mark 2")
                self.bigWishPool.removeAll()
                for snap in snapshots {
                    print("mark 3")
                    let itemInfo = snap.value as! [String: String]
                    let listID = itemInfo["listID"] as! String
                    let content = itemInfo["content"] as! String
                    var newCell = InspirationPoolViewController.cellData(itemID: snap.key, content: content, listID: listID, tags: [String]())
                    print("new cell instantialized")
                    self.bigWishPool.append(newCell)
                }
                self.performSegue(withIdentifier: "goToInspirationPool", sender: self)
            }
        })
    }
    
    @objc func searchTagViewTapped(_ recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            performSegue(withIdentifier: "goToSystemTags", sender: self)
        default:
            break
        }
    }
    
    @IBOutlet weak var motivateView: RoundRecView!{
        didSet{
            let tap = UITapGestureRecognizer(target: self, action: #selector(motivateViewTapped(_: )))
            motivateView.addGestureRecognizer(tap)
        }
    }
    
    @objc func motivateViewTapped(_ recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            performSegue(withIdentifier: "goToMotivationQuote", sender: self)
            break
        default:
            break
        }
    }
    
    private func configureLabels() {
        firstTagLabel.text = "1️⃣ "+trendingTags[0]
        secondTagLabel.text = "2️⃣ "+trendingTags[1]
        thirdTagLabel.text = "3️⃣ "+trendingTags[2]
        fourthTagLabel.text = "4️⃣ "+trendingTags[3]
        fifthTagLabel.text = "5️⃣ "+trendingTags[4]
        
        firstTagLabel.font = UIFont.preferredFont(forTextStyle: .body).withSize(firstTagLabel.bounds.height * 0.5)
        secondTagLabel.font = UIFont.preferredFont(forTextStyle: .body).withSize(secondTagLabel.bounds.height * 0.5)
        thirdTagLabel.font = UIFont.preferredFont(forTextStyle: .body).withSize(thirdTagLabel.bounds.height * 0.5)
        fourthTagLabel.font = UIFont.preferredFont(forTextStyle: .body).withSize(fourthTagLabel.bounds.height * 0.5)
        fifthTagLabel.font = UIFont.preferredFont(forTextStyle: .body).withSize(fifthTagLabel.bounds.height * 0.5)
    }
    
    override func performSegue(withIdentifier identifier: String, sender: Any?) {
        if (self.shouldPerformSegue(withIdentifier: identifier, sender: sender)) {
            super.performSegue(withIdentifier: identifier, sender: sender)
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        print("shouldPerformSegue")
        if identifier == "goToInspirationPool", sender is WorldPageViewController {
            print("shouldPerformSegue: goToInspirationPool")
            print("bigWishPool.count = \(bigWishPool.count)")
            if bigWishPool.count == 0 {
                return false
            } else {
                return true
            }
        } else {
            return true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToInspirationPool" {
            if let destination = segue.destination as? InspirationPoolViewController {
                print("preparing for segues: goToInspirationPool")
                destination.isTagSpecific = false
                destination.bigWishPool.removeAll()
                for index in self.bigWishPool.indices {
                    ref.child("List").child(bigWishPool[index].listID).child("tag").observeSingleEvent(of: .value, with: { (snapshot) in
                        if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                            print("mark 4")
                            for snap in snapshots {
                                self.bigWishPool[index].tags.append(snap.key)
                                print("tag = \(snap.key)")
                            }
                            destination.bigWishPool.append(self.bigWishPool[index])
                        }
                    })
                }
            }
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
    
    // MARK: database operations
    func getDataFromDatabase() {
        ref.child("Tag").child("tags").queryOrdered(byChild: "listCount").observe(.value, with: { (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                var reversedTrendingTags = [String]()
                for snap in snapshots{
                    let tagName = snap.key
                    reversedTrendingTags.append(tagName)
                }
                self.trendingTags = reversedTrendingTags.reversed()
            }
            self.configureLabels()
        })
    }
}
