//
//  RandomWishView.swift
//  LIST
//
//  Created by 蔡雨倩 on 07/07/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import UIKit
import FirebaseDatabase

class RandomWishView: RoundRecView {

    let ref = Database.database().reference()
    var user = LISTUser()
    var listID: String?
    var listTag: String?
    var wish: String?
    
    // MARK: tagLabel
    private lazy var tagLabel = createTagLabel()
    
    private var tagString: NSAttributedString {
        return createAttributedString("\"\(listTag!)\"", fontSize: cornerFontSize, isParagraphStyleNatural:true)
    }
    
    private func createTagLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        addSubview(label)
        return label
    }
    
    private func configureTagLabel(_ label: UILabel) {
        label.attributedText = tagString
        label.frame = CGRect(x: tagXPosition, y: tagYPosition, width: tagWidth, height: tagHeight)
    }
    
    // MARK: wishLabel
    private lazy var wishLabel = createTagLabel()
    
    private var wishString: NSAttributedString {
        return createAttributedString("\"\(wish!)\"", fontSize: cornerFontSize, isParagraphStyleNatural: false)
    }
    
    private func createWishLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        addSubview(label)
        return label
    }
    
    private func configureWishLabel(_ label: UILabel) {
        label.attributedText = tagString
        label.frame = self.bounds
    }
    
    // MARK: see the original list
    private lazy var seeButton = createButton()
    
    private func configureSeeButtonLabel(_ label: UILabel) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(seeButtonTapped(_: )))
        seeButton.addGestureRecognizer(tap)
        label.attributedText = createAttributedString("👀", fontSize: cornerFontSize, isParagraphStyleNatural: false)
        label.frame = CGRect(x: seeButtonXPosition, y: seeButtonYPosition, width: buttonSize, height: buttonSize)
    }
    
    @objc private func seeButtonTapped(_ recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            // perform segue to view the original list
            self.parentViewController!.performSegue(withIdentifier: "goToOriginalList", sender: self.parentViewController!)
            break
        default:
            break
        }
    }
    
    // MARK: fave the original list
    private lazy var favouriteButton = createButton()
    
    private func configureFavouriteButtonLabel(_ label: UILabel) {
        label.attributedText = createAttributedString("🖇", fontSize: cornerFontSize, isParagraphStyleNatural: false)
        label.frame = CGRect(x: favouriteButtonXPosition, y: favouriteButtonYPosition, width: buttonSize, height: buttonSize)
        let tap = UITapGestureRecognizer(target: self, action: #selector(favouriteButtonTapped(_: )))
        favouriteButton.addGestureRecognizer(tap)
    }
    
    @objc private func favouriteButtonTapped(_ recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            // add this list to the user's favourite lists
            var listName: String?
            ref.child("List").child(listID!).observeSingleEvent(of: .value, with: { (snapshot) in
                listName = snapshot.value as? String
            })
        ref.child("FavouriteList").child(user.userID).child(listID!).setValue(listName)
            let alert = UIAlertController(title: "Successful", message: "Just added this list to your favourite list!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.parentViewController!.present(alert, animated: true, completion: nil)
        default:
            break
        }
    }
    
    // tool methods
    private func createButton() -> UILabel {
        let label = UILabel()
        addSubview(label)
        return label
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

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setNeedsLayout()
        setNeedsDisplay()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        configureTagLabel(tagLabel)
        configureWishLabel(wishLabel)
        configureSeeButtonLabel(seeButton)
        configureFavouriteButtonLabel(favouriteButton)
    }
}
extension RandomWishView {
    private struct SizeRatio {
        static let cornerFontSizeToBoundsHeight: CGFloat = 0.2
        static let cornerOffsetToCornerRadius:CGFloat = 0.33
        static let cornerRadiusToBoundsHeight: CGFloat = 0.06
    }
    private var tagXPosition: CGFloat {
        return self.bounds.origin.x+self.frame.size.height * 0.1
    }
    private var tagYPosition: CGFloat {
        return self.bounds.origin.y+self.frame.size.height * 0.1
    }
    private var tagWidth: CGFloat {
        return self.frame.size.width * 0.7
    }
    private var tagHeight: CGFloat {
        return self.frame.size.height * 0.15
    }
    private var seeButtonXPosition: CGFloat {
        return self.bounds.origin.x+self.bounds.size.height * 0.1
    }
    private var seeButtonYPosition: CGFloat {
        return self.bounds.origin.y+self.bounds.size.height - self.bounds.size.height * 0.15
    }
    private var buttonSize: CGFloat {
        return self.frame.size.height * 0.1
    }
    private var favouriteButtonXPosition: CGFloat {
        return self.bounds.origin.x+self.bounds.size.width - self.bounds.size.height * 0.1
    }
    private var favouriteButtonYPosition: CGFloat {
        return self.bounds.origin.y+self.bounds.size.height - self.bounds.size.height * 0.15
    }
}
extension UIResponder {
    var parentViewController: UIViewController? {
        return (self.next as? UIViewController) ?? self.next?.parentViewController
    }
}
