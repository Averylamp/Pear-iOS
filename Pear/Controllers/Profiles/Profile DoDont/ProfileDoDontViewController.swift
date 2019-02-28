//
//  ProfileDoDontViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/13/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit

class ProfileDoDontViewController: UIViewController {

    var doStrings: [String]!
    var dontStrings: [String]!

    var profileDoDontHeightConstraint: NSLayoutConstraint?

    var lastItemView: UIView?

    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate(doStrings: [String], dontStrings: [String]) -> ProfileDoDontViewController? {
        let storyboard = UIStoryboard(name: String(describing: ProfileDoDontViewController.self), bundle: nil)
        guard let profileDoDontVC = storyboard.instantiateInitialViewController() as? ProfileDoDontViewController else { return nil }
        profileDoDontVC.doStrings = doStrings
        profileDoDontVC.dontStrings = dontStrings
        return profileDoDontVC
    }

}

// MARK: - Life Cycle
extension ProfileDoDontViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupDoDontViews()
    }

    enum ItemType {
        case doType
        case dontType
    }

    func addDoDontItems(text: String, type: ItemType) {
        let itemSpacing: CGFloat = 10
        let containingView = UIView()
        self.view.addSubview(containingView)
        containingView.translatesAutoresizingMaskIntoConstraints = false
        let iconImageView = UIImageView()
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        containingView.addSubview(iconImageView)

        let textLabel = UILabel()
        textLabel.numberOfLines = 0
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        containingView.addSubview(textLabel)
        let iconSize: CGFloat = 24
        self.view.addConstraints([
            NSLayoutConstraint(item: containingView, attribute: .left, relatedBy: .equal,
                               toItem: self.view, attribute: .left, multiplier: 1.0, constant: 30),
            NSLayoutConstraint(item: containingView, attribute: .right, relatedBy: .equal,
                               toItem: self.view, attribute: .right, multiplier: 1.0, constant: -30),
            NSLayoutConstraint(item: iconImageView, attribute: .left, relatedBy: .equal,
                               toItem: containingView, attribute: .left, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: iconImageView, attribute: .width, relatedBy: .equal,
                               toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: iconSize),
            NSLayoutConstraint(item: iconImageView, attribute: .height, relatedBy: .equal,
                               toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: iconSize),
            NSLayoutConstraint(item: iconImageView, attribute: .right, relatedBy: .equal,
                               toItem: textLabel, attribute: .left, multiplier: 1.0, constant: -12),
            NSLayoutConstraint(item: iconImageView, attribute: .top, relatedBy: .equal,
                               toItem: textLabel, attribute: .top, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: textLabel, attribute: .right, relatedBy: .equal,
                               toItem: containingView, attribute: .right, multiplier: 1.0, constant: itemSpacing),
            NSLayoutConstraint(item: textLabel, attribute: .bottom, relatedBy: .equal,
                               toItem: containingView, attribute: .bottom, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: textLabel, attribute: .top, relatedBy: .equal,
                               toItem: containingView, attribute: .top, multiplier: 1.0, constant: itemSpacing)
            ])
        if let lastItemView = self.lastItemView {
            self.view.addConstraint(NSLayoutConstraint(item: containingView, attribute: .top, relatedBy: .equal,
                                                       toItem: lastItemView, attribute: .bottom, multiplier: 1.0, constant: 0.0))
        } else {
            self.view.addConstraint(NSLayoutConstraint(item: containingView, attribute: .top, relatedBy: .equal,
                                                       toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0.0))
        }
        self.lastItemView = containingView

        let correctedText = String(text.prefix(1)).lowercased() + String(text.dropFirst())

        switch type {
        case .doType:
            iconImageView.image = UIImage(named: "profile-icon-thumb-do")
            let fullDoText = NSMutableAttributedString()
            fullDoText.append(NSAttributedString(string: "Do ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .bold)]))
            fullDoText.append(NSAttributedString(string: correctedText, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .regular)]))
            textLabel.attributedText = fullDoText
        case .dontType:
            iconImageView.image = UIImage(named: "profile-icon-thumb-dont")
            let fullDoText = NSMutableAttributedString()
            fullDoText.append(NSAttributedString(string: "Don't ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .bold)]))
            fullDoText.append(NSAttributedString(string: correctedText, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .regular)]))
            textLabel.attributedText = fullDoText
        }
    }

    func setupDoDontViews() {
        for doString in self.doStrings {
            self.addDoDontItems(text: doString, type: .doType)
        }
        for dontString in self.dontStrings {
            self.addDoDontItems(text: dontString, type: .dontType)
        }

    }

    func setHeightConstraint(constraint: NSLayoutConstraint) {
        self.profileDoDontHeightConstraint = constraint
        self.view.layoutIfNeeded()
        if let lastContainer = self.lastItemView {
            self.profileDoDontHeightConstraint?.constant = lastContainer.frame.origin.y + lastContainer.frame.height + 12
        }
    }
}
