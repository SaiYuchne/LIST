//
//  TagsTableViewController.swift
//  LIST
//
//  Created by 蔡雨倩 on 14/06/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import UIKit

class TagsTableViewController: UITableViewController {

    private var cellTitle = ["Love", "Travel", "YOLO", "Add more tags"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellTitle.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row+1 < cellTitle.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "userTagCell", for: indexPath)
            cell.textLabel?.text = cellTitle[indexPath.row]
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "addTagCell", for: indexPath)
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == cellTitle.count - 1 {
            self.performSegue(withIdentifier: "goToTagCollection", sender: self)
        }
    }
 
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row + 1 < cellTitle.count{
            return true
        }
        return false
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            if indexPath.row+1 != tableView.numberOfRows(inSection: 0){
                let alert = UIAlertController(title: "Warning", message: "Delete this tag?", preferredStyle: .alert)
                let no = UIAlertAction(title: "No", style: .cancel, handler: nil)
                let yes = UIAlertAction(title: "Yes", style: .default) { (_) in
                    // remove the tag from the database
                    self.cellTitle.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                }
                alert.addAction(no)
                alert.addAction(yes)
                present(alert, animated: true, completion: nil)
            }
        }
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
