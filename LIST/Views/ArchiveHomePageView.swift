//
//  ArchiveHomePageView.swift
//  LIST
//
//  Created by 蔡雨倩 on 21/06/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ArchiveHomePageView: RoundRecView {

    let ref = Database.database().reference()
    private let user = LISTUser()
    
    private lazy var label = createLabel()
    
    private var labelString: NSAttributedString {
        let creationDate = ref.child("User").child(user.userID).value(forKey: "creationDate") as! String
        let count = ref.child("Archive").child("count").value(forKey: user.userID) as! Int
        return centeredAttributedString(first: "Since \(creationDate), \n you have completed ", second: "\n \(count) \n", third: "lists in total\n Flip to go through\n your amazing journey", fontSize: fontSize)
    }
    
    private func createLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        addSubview(label)
        return label
    }
    
    private func configureLabel(_ label: UILabel) {
        label.attributedText = labelString
        label.frame = self.bounds
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setNeedsLayout()
        setNeedsDisplay()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        configureLabel(label)
    }
    
    private func centeredAttributedString(first: String, second: String, third: String, fontSize: CGFloat) -> NSAttributedString {
        let string = first + second + third as NSString
        let result = NSMutableAttributedString(string: string as String)
        var font = UIFont.preferredFont(forTextStyle: .body).withSize(fontSize)
        font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let attributesForSecondWord = [
            NSAttributedStringKey.foregroundColor : UIColor(red: 13/255.0, green: 196/255.0, blue: 224/255.0, alpha: 1.0)
                    ]
        
        result.setAttributes(attributesForSecondWord, range: string.range(of: second))
        result.setAttributes([.paragraphStyle:paragraphStyle,.font:font], range: string.range(of: string as String))
        
        return NSAttributedString(attributedString: result)
    }
    
}
extension ArchiveHomePageView {
    var fontSize: CGFloat {
        return bounds.size.height * 0.2
    }
}