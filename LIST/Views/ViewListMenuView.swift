//
//  ViewListMenuView.swift
//  LIST
//
//  Created by 蔡雨倩 on 11/06/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import UIKit

class ViewListMenuView: RoundRecView {

    private static var byDeadline = false
    private static var byPriority = false
    private static var byTag = true
    
    private lazy var menuLabel = createLabel()
    
    private var infoString: NSAttributedString {
        if(ViewListMenuView.byDeadline) {
            ViewListMenuView.byDeadline = !ViewListMenuView.byDeadline
            ViewListMenuView.byPriority = !ViewListMenuView.byPriority
            return centeredAttributedString("View by\n deadline", fontSize: fontSize)
        } else if(ViewListMenuView.byPriority) {
            ViewListMenuView.byPriority = !ViewListMenuView.byPriority
            ViewListMenuView.byTag = !ViewListMenuView.byTag
            return centeredAttributedString("View by\n priority", fontSize: fontSize)
        } else {
            ViewListMenuView.byTag = !ViewListMenuView.byTag
            ViewListMenuView.byDeadline = !ViewListMenuView.byDeadline
            return centeredAttributedString("View by\n tags", fontSize: fontSize)
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        configureLabel(label: menuLabel)
    }
    
    private func createLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        addSubview(label)
        return label
    }
    
    func configureLabel(label: UILabel){
        label.attributedText = infoString
        label.frame = self.bounds
    }
    
    private func centeredAttributedString(_ string: String, fontSize: CGFloat) -> NSAttributedString {
        var font = UIFont.preferredFont(forTextStyle: .body).withSize(fontSize)
        font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        return NSAttributedString(string: string, attributes: [.paragraphStyle:paragraphStyle,.font:font])
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setNeedsLayout()
        setNeedsDisplay()
    }
}

extension ViewListMenuView {
    var fontSize: CGFloat {
        return bounds.size.height * 0.2
    }
}
