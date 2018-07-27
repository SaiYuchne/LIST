//
//  ProgressOverviewViewController.swift
//  LIST
//
//  Created by 蔡雨倩 on 26/07/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ProgressOverviewViewController: UIViewController {

    let ref = Database.database().reference()
    
    @IBOutlet weak var itemNameLabel: UILabel!
    var listID: String?
    var itemName: String?
    var itemID: String?
    
    @IBOutlet weak var timelineView: UIView!
    lazy var timeline = ISTimeline(frame: timelineView.bounds)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureItemNameLabel(itemNameLabel)
        timelineView.addSubview(timeline)
        initializeTimeline()
    }

    func configureItemNameLabel(_ label: UILabel){
        if let name = itemName {
            itemNameLabel.attributedText = centeredAttributedString(name, fontSize: itemNameLabel.bounds.size.height * 0.7)
        }
    }
    
    private func centeredAttributedString(_ string: String, fontSize: CGFloat) -> NSAttributedString {
        var font = UIFont.preferredFont(forTextStyle: .body).withSize(fontSize)
        font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        return NSAttributedString(string: string, attributes: [.paragraphStyle:paragraphStyle,.font:font])
    }
    
    func initializeTimeline() {
        timeline.backgroundColor = .white
        timeline.backgroundColor = .white
        timeline.bubbleColor = .init(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
        timeline.titleColor = .black
        timeline.descriptionColor = .darkText
        timeline.pointDiameter = 7.0
        timeline.lineWidth = 2.0
        timeline.bubbleRadius = 0.0
        
        getNodeDataFromDatabase()
    }

    // MARK: database operation
    func getNodeDataFromDatabase() {
        let progressRef = ref.child("Progress").child(itemID!)
        progressRef.queryOrdered(byChild: "creationDays").observe(.value) { (snapshot) in
            self.timeline.points.removeAll()
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                for snap in snapshots {
                    let tempData = snap.value as! Dictionary<String, Any>
                    let point = ISPoint(title: tempData["date"] as! String)
                    point.nodeID = snap.key
                    point.description = tempData["content"] as! String
                    point.lineColor = .black
                    point.pointColor = point.lineColor
                    
                    self.timeline.points.insert(point, at: 0)
                }
            }
        }
    }
}
