//
//  CreateViewController.swift
//  LIST
//
//  Created by 蔡雨倩 on 08/06/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import UIKit

class CreateViewController: UIViewController {

    var listName: String?
    
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
            self.performSegue(withIdentifier: "goToCreateList", sender: self)
            // prepare for segue
        }
        alert.addAction(cancel)
        alert.addAction(create)
        present(alert, animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToCreateList" {
            if let destination = segue.destination as? SingleListViewController {
                destination.listName = listName
            }
        }
    }

}
