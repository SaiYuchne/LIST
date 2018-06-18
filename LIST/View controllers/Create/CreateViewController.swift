//
//  CreateViewController.swift
//  LIST
//
//  Created by 蔡雨倩 on 08/06/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import UIKit
import FirebaseDatabase

class CreateViewController: UIViewController {
    let ref = Database.database().reference()
    
    var listName: String?
    var listID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func createListTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Create a list", message: "Give your list a name:", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Type the list name here"
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let create = UIAlertAction(title: "Create", style: .default) { (_) in
            self.listName = alert.textFields?[0].text
            self.createListInDatabase(listTitle: self.listName!)
            self.performSegue(withIdentifier: "goToCreateList", sender: self)
            // prepare for segue
        }
        alert.addAction(cancel)
        alert.addAction(create)
        present(alert, animated: true, completion: nil)
    }

    func createListInDatabase(listTitle: String){
        let user = LISTUser()
        
        // generates a random key
        let key = ref.child("List").childByAutoId().key
        listID = key
        
        // update List
        let defaultListInfo = ["listTitle": listTitle, "userID": user.userID, "privacy": "personal", "priority": nil, "deadline": nil, "creationDate": Date().toString(dateFormat: "dd-MM-yyyy"), "tag": [String](), "collaborator": [String](), "isFinished": false] as [String : Any?]
        ref.child("List").child(key).setValue(defaultListInfo)
        // update ListItem
        ref.child("ListItem").child(key).child("itemNo").setValue(0)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToCreateList" {
            if let destination = segue.destination as? SingleListViewController {
                destination.listName = listName
                destination.listID = listID
            }
        }
    }

}
