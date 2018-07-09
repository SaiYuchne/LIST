//
//  InspirationPoolExtractView.swift
//  LIST
//
//  Created by 蔡雨倩 on 07/07/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import UIKit

class InspirationPoolExtractView: UIView {
    
    private lazy var label = createLabel()
    
    private func createLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 1
        addSubview(label)
        return label
    }

    private func configureLabel(_ label: UILabel) {
        label.attributedText = centeredAttributedString("Get a dive!💦", fontSize: cornerFontSize)
        label.frame = self.frame
    }
    
    override func draw(_ rect: CGRect) {
        let roundedRect = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        roundedRect.addClip()
        UIColor.init(red: 31/255, green: 54/255, blue: 130/255, alpha: 1).setFill()
        roundedRect.fill()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setNeedsLayout()
        setNeedsDisplay()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureLabel(label)
    }
    
    private func centeredAttributedString(_ string: String, fontSize: CGFloat) -> NSAttributedString {
        var font = UIFont.preferredFont(forTextStyle: .body).withSize(fontSize)
        font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        return NSAttributedString(string: string, attributes: [.paragraphStyle:paragraphStyle,.font:font])
    }
}
extension InspirationPoolExtractView {
    struct SizeRatio {
        static let cornerFontSizeToBoundsHeight: CGFloat = 0.13
        static let cornerOffsetToCornerRadius:CGFloat = 0.33
        static let cornerRadiusToBoundsHeight: CGFloat = 0.06
    }
    var cornerRadius: CGFloat {
        return bounds.size.height * SizeRatio.cornerRadiusToBoundsHeight
    }
    var cornerFontSize: CGFloat {
        return bounds.size.height * SizeRatio.cornerFontSizeToBoundsHeight
    }
    var cornerOffset: CGFloat {
        return cornerRadius * SizeRatio.cornerOffsetToCornerRadius
    }
}
