//
//  WorldPageViewController.swift
//  LIST
//
//  Created by 蔡雨倩 on 07/07/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import UIKit
import FirebaseDatabase

class WorldPageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let ref = Database.database().reference()
    private lazy var user = LISTUser()
    
    @IBOutlet weak var inspirationPoolExtractView: InspirationPoolExtractView! {
        didSet{
            let tap = UITapGestureRecognizer(target: self, action: #selector(inspirationPoolExtractTapped(_: )))
            inspirationPoolExtractView.addGestureRecognizer(tap)
        }
    }
    
    @IBOutlet weak var trendingTagsTableView: UITableView!
    
    var trendingTags = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        trendingTagsTableView.delegate = self
        trendingTagsTableView.dataSource = self
        getDataFromDatabase()
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trendingTags.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "trendingTagCell") as? TrendingTagTableViewCell else {return UITableViewCell()}
            cell.tagLabel.text = trendingTags[indexPath.row]
            return cell
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
