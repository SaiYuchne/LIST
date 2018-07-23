//
//  SettingsTableViewController.swift
//  LIST
//
//  Created by 蔡雨倩 on 08/06/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import UIKit
import FirebaseDatabase

class SettingsTableViewController: UITableViewController {

    private var infoTitle = ["Personal profile", "System settings"]
    let userID = LISTUser().userID
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath)

        cell.textLabel?.text = infoTitle[indexPath.row]
        cell.accessoryType = .disclosureIndicator

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            self.performSegue(withIdentifier: "goToProfile", sender: self)
        } else {
            self.performSegue(withIdentifier: "goToSystemSettings", sender: self)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("Prepare segue for goToProfile")
        if segue.identifier == "goToProfile" {
            print("first layer")
            if let destination = segue.destination as? ProfileTableViewController {
                print("second layer")
                let userRef = Database.database().reference().child("Profile").child(userID)
                userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                    if let userInfo = snapshot.value as? [String: AnyObject] {
                        destination.userName = userInfo["userName"] as! String
                        print(userInfo["userName"] as! String)
                        destination.gender = userInfo["gender"] as! String
                        print(userInfo["gender"] as! String)
                        destination.birthDate = userInfo["birthDate"] as! String
                        print(userInfo["birthDate"] as! String)
                        destination.motto = userInfo["motto"] as! String
                        print(userInfo["motto"] as! String)
                        destination.email = userInfo["email"] as! String
                        print(userInfo["email"] as! String)
                    }
                })
                
                destination.tableView.reloadData()
            }
        }
    }

}
