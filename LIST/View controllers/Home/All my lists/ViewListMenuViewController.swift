//
//  ViewListMenuViewController.swift
//  LIST
//
//  Created by 蔡雨倩 on 11/06/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import UIKit

class ViewListMenuViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewByPriority" {
            if let destination = segue.destination as? ViewListViewController {
                destination.byPriority = true
            }
        } else if segue.identifier == "viewByDeadline" {
            if let destination = segue.destination as? ViewListViewController {
                destination.byDeadline = true
            }
        } else {
            if let destination = segue.destination as? ViewListViewController {
                destination.byTag = true
            }
        }
    }

}
