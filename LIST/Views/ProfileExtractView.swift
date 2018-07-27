//
//  ProfileExtractView.swift
//  LIST
//
//  Created by 蔡雨倩 on 03/06/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ProfileExtractView: UIView {

    var user = LISTUser()
    var isFaceUp = true {
        didSet{
            setNeedsLayout()
            setNeedsDisplay()
        }
    }
    
    var userName = String()
    var motto: String? 
    var creationDays = Int()
    
    // MARK: mottoLabel
    private lazy var mottoLabel = createMottoLabel()
    
    private var mottoString: NSAttributedString {
        if let motto = motto {
            return createAttributedString("\"\(motto)\"", fontSize: cornerFontSize, isParagraphStyleNatural:true)
        }
        return createAttributedString("\"You only live once\"", fontSize: cornerFontSize, isParagraphStyleNatural:true)
    }
    
    private func createMottoLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        addSubview(label)
        return label
    }
    
    private func configureMottoLabel(_ label: UILabel) {
        label.attributedText = mottoString
        label.frame = CGRect(x: textXPosition, y: mottoYPosition, width: self.frame.size.width * 0.7, height: self.frame.size.height * 0.45)
    }
    
    // MARK: usernameLabel
    private lazy var usernameLabel = createMottoLabel()
    
    private var usernameString: NSAttributedString {
        return createAttributedString("\(userName)", fontSize: cornerFontSize*0.8, isParagraphStyleNatural:true)
    }
    
    private func createUsernameLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 1
        addSubview(label)
        return label
    }
    
    private func configureUsernameLabel(_ label: UILabel) {
        label.attributedText = usernameString
        label.frame = CGRect(x: textXPosition, y: usernameYPosition, width: self.frame.size.width * 0.7, height: self.frame.size.height * 0.35)
    }
    
    // MARK: iconPIC
    private lazy var iconPic = createIconPic()
    var iconImage: UIImage?
    // todo: how to upload iconPic
    func createIconPic() -> UIImageView {
        let iconImageView = UIImageView()
        iconImageView.frame = CGRect(x: picXPosition, y: self.bounds.origin.y+self.frame.size.height * 0.1, width: self.frame.size.width * 0.25, height: self.frame.size.height * 0.8)
        addSubview(iconImageView)
        return iconImageView
    }
    
    func configureIconPic(_ imageView: UIImageView) {
        if let image = iconImage {
            imageView.image = image
        } else {
            imageView.image = UIImage(named: "icon")
        }
        imageView.contentMode = .scaleAspectFill
    }
    
    // MARK: dayLabel
    private lazy var dayLabel = createDayLabel()
    
    private var dayString: NSAttributedString {
        return createAttributedString("LIST has been there with you for\n \(calculateDateDifference(from: creationDays)) days!", fontSize: cornerFontSize*0.8, isParagraphStyleNatural:false)
    }
    
    private func createDayLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        addSubview(label)
        return label
    }
    
    private func configureDayLabel(_ label: UILabel) {
        label.attributedText = dayString
        label.frame = self.bounds
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        setNeedsLayout()
        setNeedsDisplay()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        configureMottoLabel(mottoLabel)
        configureUsernameLabel(usernameLabel)
        configureIconPic(iconPic)
        configureDayLabel(dayLabel)
        
        if isFaceUp {
            mottoLabel.isHidden = false
            usernameLabel.isHidden = false
            iconPic.isHidden = false
            dayLabel.isHidden = true
        } else {
            mottoLabel.isHidden = true
            usernameLabel.isHidden = true
            iconPic.isHidden = true
            dayLabel.isHidden = false
        }
    }
    
    private func createAttributedString(_ string: String, fontSize: CGFloat, isParagraphStyleNatural: Bool) -> NSAttributedString {
        var font = UIFont.preferredFont(forTextStyle: .body).withSize(fontSize)
        font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
        let paragraphStyle = NSMutableParagraphStyle()
        if isParagraphStyleNatural{
            paragraphStyle.alignment = .natural
        } else {
            paragraphStyle.alignment = .center
        }
        return NSAttributedString(string: string, attributes: [.paragraphStyle:paragraphStyle,.font:font])
    }
    
    override func draw(_ rect: CGRect) {
         let roundedRect = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        roundedRect.addClip()
        UIColor.white.setFill()
        roundedRect.fill()
    }
    
    // MARK: calculate the time difference
    func calculateDateDifference(from date1: Int) -> Int {
        let todayIntervalBySecond = Date().timeIntervalSinceReferenceDate
        let todayInterval = Int(todayIntervalBySecond/(3600 * 24))
        let difference = todayInterval - date1
        return difference
    }
}

extension ProfileExtractView {
    private struct SizeRatio {
        static let cornerFontSizeToBoundsHeight: CGFloat = 0.2
        static let cornerOffsetToCornerRadius:CGFloat = 0.33
        static let cornerRadiusToBoundsHeight: CGFloat = 0.06
    }
    private var cornerRadius: CGFloat {
        return bounds.size.height * SizeRatio.cornerRadiusToBoundsHeight
    }
    private var cornerFontSize: CGFloat {
        return bounds.size.height * SizeRatio.cornerFontSizeToBoundsHeight
    }
    private var cornerOffset: CGFloat {
        return cornerRadius * SizeRatio.cornerOffsetToCornerRadius
    }
    private var picXPosition: CGFloat {
        return self.bounds.origin.x+self.frame.size.height * 0.1
    }
    private var picYPosition: CGFloat {
        return self.bounds.origin.y+self.frame.size.height * 0.1
    }
    private var picWidth: CGFloat {
        return self.frame.size.width * 0.25
    }
    private var textXPosition: CGFloat {
        return picXPosition * 2 + picWidth
    }
    private var usernameYPosition: CGFloat {
        return picYPosition
    }
    private var mottoYPosition: CGFloat {
        return usernameYPosition + self.frame.size.height * 0.2
    }
}

extension CGPoint {
    func offsetBy(dx: CGFloat, dy: CGFloat) -> CGPoint {
        return CGPoint(x: x+dx, y: y+dy)
    }
}
