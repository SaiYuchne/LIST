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
    private lazy var user = LISTUser()
    
    @IBOutlet weak var inspirationPoolExtractView: InspirationPoolExtractView! {
        didSet{
            let tap = UITapGestureRecognizer(target: self, action: #selector(inspirationPoolExtractTapped(_: )))
            inspirationPoolExtractView.addGestureRecognizer(tap)
        }
    }
    
    var trendingTags = [String]()
    
    @IBOutlet weak var firstTagLabel: UILabel!
    @IBOutlet weak var secondTagLabel: UILabel!
    @IBOutlet weak var thirdTagLabel: UILabel!
    @IBOutlet weak var fourthTagLabel: UILabel!
    @IBOutlet weak var fifthTagLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getDataFromDatabase()
        configureLabels()
    }
    
    @objc private func inspirationPoolExtractTapped(_ recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            performSegue(withIdentifier: "goToInspirationPool", sender: self)
            break
        default:
            break
        }
    }
    
    @IBOutlet weak var searchTagView: RoundRecView!{
        didSet{
            let tap = UITapGestureRecognizer(target: self, action: #selector(searchTagViewTapped(_: )))
            searchTagView.addGestureRecognizer(tap)
        }
    }
    
    @objc func searchTagViewTapped(_ recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            performSegue(withIdentifier: "goToSystemTags", sender: self)
            break
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
            // perform segue
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
        
        firstTagLabel.font = UIFont.preferredFont(forTextStyle: .body).withSize(firstTagLabel.bounds.height * 0.9)
        secondTagLabel.font = UIFont.preferredFont(forTextStyle: .body).withSize(secondTagLabel.bounds.height * 0.9)
        thirdTagLabel.font = UIFont.preferredFont(forTextStyle: .body).withSize(thirdTagLabel.bounds.height * 0.9)
        fourthTagLabel.font = UIFont.preferredFont(forTextStyle: .body).withSize(fourthTagLabel.bounds.height * 0.9)
        fifthTagLabel.font = UIFont.preferredFont(forTextStyle: .body).withSize(fifthTagLabel.bounds.height * 0.9)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToInspirationPool" {
            if let destination = segue.destination as? InspirationPoolViewController {
                destination.isTagSpecific = false
            }
        }
    }
    
    // MARK: database operations
    private func getDataFromDatabase() {
        let trendingTagsRef = ref.child("Tag").child("tags").queryOrdered(byChild: "listCount")
        
        trendingTagsRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                var tagCount = 0
                for snap in snapshots{
                    let tagName = snap.key
                    self.trendingTags.append(tagName)
                    tagCount += 1
                    if tagCount >= 5 {
                        break
                    }
                }
            }
        })
    }
}
