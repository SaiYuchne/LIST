//
//  MotivationQuoteViewController.swift
//  LIST
//
//  Created by 蔡雨倩 on 12/07/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import UIKit
import FirebaseDatabase

class MotivationQuoteViewController: UIViewController {

    @IBOutlet weak var motivationQuoteView: MotivationQuoteView!
    
    let ref = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        motivationQuoteView.translatesAutoresizingMaskIntoConstraints = false

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        motivationQuoteView.translatesAutoresizingMaskIntoConstraints = false
        ref.child("MotivationQuote").observe(.value) { (snapshot) in
            self.motivationQuoteView.quote = snapshot.value as! String
        }
    }
}
