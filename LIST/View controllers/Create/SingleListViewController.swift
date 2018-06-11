//
//  SingleListViewController.swift
//  LIST
//
//  Created by 蔡雨倩 on 08/06/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import UIKit

class SingleListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var listNameLabel: UILabel!
    var listName: String?
    
    var goals: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        configureListNameLabel(listNameLabel)
        
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
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return goals.count + 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("indexPath.row = \(indexPath.row)")
        print("tableView.numberOfRows(inSection: 0) = \(tableView.numberOfRows(inSection: 0))")
        if indexPath.row+1 != tableView.numberOfRows(inSection: 0){
            if let cell = tableView.dequeueReusableCell(withIdentifier: "listItemCell", for: indexPath) as? ListItemTableViewCell{
                cell.goalLabel.text = goals[indexPath.row]
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
                self.goals.append(wish)
                self.tableView.reloadData()
            }
        }
        alert.addAction(cancel)
        alert.addAction(add)
        present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            if indexPath.row+1 != tableView.numberOfRows(inSection: 0){
                let alert = UIAlertController(title: "Warning", message: "Delete this wish?", preferredStyle: .alert)
                let no = UIAlertAction(title: "No", style: .cancel, handler: nil)
                let yes = UIAlertAction(title: "Yes", style: .default) { (_) in
                    self.goals.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                }
                alert.addAction(no)
                alert.addAction(yes)
                present(alert, animated: true, completion: nil)
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
