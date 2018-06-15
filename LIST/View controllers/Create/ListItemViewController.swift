//
//  ListItemViewController.swift
//  LIST
//
//  Created by 蔡雨倩 on 12/06/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import UIKit

class ListItemViewController: UIViewController {

    @IBOutlet weak var itemNameLabel: UILabel!
    var itemName: String?
    
    @IBOutlet weak var timeLineView: UIView!
    lazy var timeline = ISTimeline(frame: timeLineView.bounds)
    
    var points = [ISPoint]()
    
    private var addNode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureItemNameLabel(itemNameLabel)
        timeLineView.addSubview(timeline)
        initializeTimeline()
    }

    func configureItemNameLabel(_ label: UILabel){
        if let name = itemName {
            itemNameLabel.attributedText = centeredAttributedString(name, fontSize: itemNameLabel.bounds.size.height * 0.7)
        }
    }
    
    func initializeTimeline() {

        print("initialize the timeline properties")
        timeline.backgroundColor = .white
        timeline.backgroundColor = .white
        timeline.bubbleColor = .init(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
        timeline.titleColor = .black
        timeline.descriptionColor = .darkText
        timeline.pointDiameter = 7.0
        timeline.lineWidth = 2.0
        timeline.bubbleRadius = 0.0
        
        timeline.points = points
        
        let point = ISPoint(title: "Click here to add a node")
        point.description = "Document your progress so when you look back, you will thank yourself!"
        point.lineColor = .black
        point.pointColor = point.lineColor
        point.touchUpInside =
            { (point:ISPoint) in
                self.addNode = true
                self.addANode()
        }
        
        timeline.points.append(point)
        
    }
    
    func addANode() {
        self.performSegue(withIdentifier: "goToNodeSetting", sender: self)
        // update the new node from the database
        let point = ISPoint(title: "2018-06-30")
        point.description = "my awesome description"
        point.lineColor = .black
        point.pointColor = point.lineColor
        point.touchUpInside =
            { (point:ISPoint) in
                self.addNode = false
                self.performSegue(withIdentifier: "goToNodeSetting", sender: self)
        }
        
        timeline.points.insert(point, at: 1)
        
    }
    
    private func centeredAttributedString(_ string: String, fontSize: CGFloat) -> NSAttributedString {
        var font = UIFont.preferredFont(forTextStyle: .body).withSize(fontSize)
        font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        return NSAttributedString(string: string, attributes: [.paragraphStyle:paragraphStyle,.font:font])
    }
    
    @IBAction func itemNameTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Edit", message: "Edit the goal:", preferredStyle: .alert)
        var newName: String?
        alert.addTextField { (textField) in
            textField.placeholder = "Type here"
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let edit = UIAlertAction(title: "Save", style: .default) { (_) in
            newName = alert.textFields?[0].text
            if newName != nil {
                // change the list name in database
                print(newName!)
                self.itemNameLabel.text = newName!
            }
        }
        alert.addAction(cancel)
        alert.addAction(edit)
        present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToNodeSetting" {
            if let destination = segue.destination as? DocumentNodeViewController {
                destination.addNode = false
            }
        }
    }
    
    // MARK: Dismiss the keyboard
    // when touching outside
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    // when pressing return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
