//
//  MotivationQuoteView.swift
//  LIST
//
//  Created by 蔡雨倩 on 12/07/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import UIKit

class MotivationQuoteView: RoundRecView {

    var quote: String?
    
    // MARK: motivationLabel
    private lazy var motivationLabel = createTagLabel()
    
    private var tagString: NSAttributedString {
        return centeredAttributedString("\"\(quote!)\"", fontSize: cornerFontSize)
    }
    
    private func createTagLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        addSubview(label)
        return label
    }
    
    private func configureTagLabel(_ label: UILabel) {
        label.attributedText = centeredAttributedString(quote!, fontSize: labelFontSize)
        label.frame = self.frame
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
        static let fontSizeToBoundsHeight: CGFloat = 0.8
        static let cornerOffsetToCornerRadius:CGFloat = 0.33
        static let cornerRadiusToBoundsHeight: CGFloat = 0.06
    }
    var labelFontSize: CGFloat {
        return bounds.size.height * SizeRatio.fontSizeToBoundsHeight
    }
}
