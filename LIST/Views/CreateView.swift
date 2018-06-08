//
//  CreateView.swift
//  LIST
//
//  Created by 蔡雨倩 on 08/06/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import UIKit

class CreateView: RoundRecView {
    
    private static var isCreateList = false
    
    private lazy var listLabel = createLabel()
    
    private var infoString: NSAttributedString {
        if(CreateView.isCreateList) {
            CreateView.isCreateList = !CreateView.isCreateList
            return centeredAttributedString("Create\n a list", fontSize: cornerFontSize)
        } else {
            CreateView.isCreateList = !CreateView.isCreateList
            return centeredAttributedString("Document\n progress", fontSize: cornerFontSize)
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        configureLabel(label: listLabel)
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
