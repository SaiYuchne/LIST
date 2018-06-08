//
//  HomePageListExtractView.swift
//  LIST
//
//  Created by 蔡雨倩 on 04/06/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import UIKit

class HomePageListExtractView: RoundRecView {
    
    var user = LISTUser()
    
    private static var isMostImportantList = true

    
    // MARK: mottoLabel
    private lazy var mottoLabel = createMottoLabel()
    
    private var mottoString: NSAttributedString {
        if(HomePageListExtractView.isMostImportantList){
            HomePageListExtractView.isMostImportantList = !HomePageListExtractView.isMostImportantList
            return centeredAttributedString("most important", fontSize: fontSize)
        }else{
            HomePageListExtractView.isMostImportantList = !HomePageListExtractView.isMostImportantList
            return centeredAttributedString("most urgent", fontSize: fontSize)
        }
    }
    
    private func createMottoLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        addSubview(label)
        return label
    }
    
    private func configureMottoLabel(_ label: UILabel) {
        label.attributedText = mottoString
        label.frame = self.bounds
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setNeedsLayout()
        setNeedsDisplay()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        configureMottoLabel(mottoLabel)
    }
    
    private func centeredAttributedString(_ string: String, fontSize: CGFloat) -> NSAttributedString {
        var font = UIFont.preferredFont(forTextStyle: .body).withSize(fontSize)
        font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        return NSAttributedString(string: string, attributes: [.paragraphStyle:paragraphStyle,.font:font])
    }
}

extension HomePageListExtractView {
    var fontSize: CGFloat {
        return bounds.size.height * 0.3
    }
}
