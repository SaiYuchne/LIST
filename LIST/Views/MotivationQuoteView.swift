//
//  MotivationQuoteView.swift
//  LIST
//
//  Created by 蔡雨倩 on 12/07/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import UIKit

class MotivationQuoteView: RoundRecView {

    var quote = String() {
        didSet {
            layoutSubviews()
        }
    }
    
    // MARK: motivationLabel
    private lazy var motivationLabel = createTagLabel()
    
    private var tagString: NSAttributedString {
        return centeredAttributedString("\"\(quote)\"", fontSize: cornerFontSize)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        configureTagLabel(motivationLabel)
    }
    
    private func createTagLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        addSubview(label)
        return label
    }
    
    private func configureTagLabel(_ label: UILabel) {
        label.attributedText = centeredAttributedString(quote, fontSize: labelFontSize)
        label.frame = CGRect(x: textXPosition, y: textYPosition, width: self.frame.size.width * 0.7, height: self.frame.size.height * 0.7)
    }

    private func centeredAttributedString(_ string: String, fontSize: CGFloat) -> NSAttributedString {
        var font = UIFont.preferredFont(forTextStyle: .body).withSize(fontSize)
        font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        return NSAttributedString(string: string, attributes: [.paragraphStyle:paragraphStyle,.font:font])
    }
    
}
extension MotivationQuoteView {
    struct SizeRatio {
        static let fontSizeToBoundsHeight: CGFloat = 0.1
        static let cornerOffsetToCornerRadius:CGFloat = 0.33
        static let cornerRadiusToBoundsHeight: CGFloat = 0.06
    }
    var labelFontSize: CGFloat {
        return bounds.size.height * SizeRatio.fontSizeToBoundsHeight
    }
    private var textXPosition: CGFloat {
        return self.bounds.origin.x+self.frame.size.height * 0.1
    }
    private var textYPosition: CGFloat {
        return self.bounds.origin.y+self.frame.size.height * 0.1
    }
}
