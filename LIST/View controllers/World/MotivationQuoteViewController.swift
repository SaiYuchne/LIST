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

        sendQuote()
    }
    
    private func sendQuote() {
        ref.child("MotivationQuote").observeSingleEvent(of: .value) { (snapshot) in
            self.motivationQuoteView.quote = snapshot.value as? String
        }
    }
}
