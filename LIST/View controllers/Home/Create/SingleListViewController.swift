//
//  SingleListViewController.swift
//  LIST
//
//  Created by 蔡雨倩 on 08/06/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import UIKit

class SingleListViewController: UIViewController {

    
    @IBOutlet weak var listNameLabel: UILabel!
    var listName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let name = listName {
            listNameLabel.text = name
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
