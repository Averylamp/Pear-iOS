//
//  SummaryProfileViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/14/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit

class SummaryProfileViewController: UIViewController {

    var profileData: ProfileData!
    let seperatorViewColor: UIColor = UIColor(white: 0.2, alpha: 0.1)

    @IBOutlet var stackView: UIStackView!
    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate(profileData: ProfileData) -> SummaryProfileViewController? {
        let storyboard = UIStoryboard(name: String(describing: SummaryProfileViewController.self), bundle: nil)
        guard let summaryProfileVC = storyboard.instantiateInitialViewController() as? SummaryProfileViewController else { return nil }
        summaryProfileVC.profileData = profileData
        return summaryProfileVC
    }

    func setHeightConstraint(constraint: NSLayoutConstraint) {
        constraint.constant = self.stackView.intrinsicContentSize.height
    }

}

// MARK: - Life Cycle
extension SummaryProfileViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addProfileImageVC()
        self.addSeperator()
        self.addInformationVC()
        self.addSeperator()
        self.addDoDontVC()
    }

    func addProfileImageVC() {
        guard let profileImageVC = ProfileImageViewController.instantiate(images: [self.profileData.images.first!]) else {
            print("Failed to create profile Image VC")
            return
        }
        self.addChild(profileImageVC)
        self.stackView.addArrangedSubview(profileImageVC.view)
        profileImageVC.didMove(toParent: self)
        profileImageVC.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraints([
            NSLayoutConstraint(item: profileImageVC.view, attribute: .width, relatedBy: .equal,
                               toItem: self.stackView, attribute: .width, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: profileImageVC.view, attribute: .height, relatedBy: .equal,
                               toItem: self.stackView, attribute: .width, multiplier: 1.0, constant: 0.0)])

        self.view.layoutIfNeeded()
    }

    func addInformationVC() {
        var endorsedName = self.profileData.endorsedFirstName!
        if let endorsedLastName = self.profileData.endorsedLastName {
            endorsedName += " " + String(endorsedLastName.prefix(1)) + "."
        }

        if let profileInformationVC = ProfileInformationViewController.instantiate(firstName: self.profileData.firstName,
                                                                                age: self.profileData.age,
                                                                                endorsedName: endorsedName,
                                                                                locationData: self.profileData.locationData,
                                                                                schoolName: self.profileData.schoolName,
                                                                                workData: self.profileData.work) {
            self.addChild(profileInformationVC)
            self.stackView.addArrangedSubview(profileInformationVC.view)
            profileInformationVC.didMove(toParent: self)
            profileInformationVC.view.translatesAutoresizingMaskIntoConstraints = false
            let profileInformationHeightConstraint =
                NSLayoutConstraint(item: profileInformationVC.view, attribute: .height, relatedBy: .equal,
                                   toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40)
            self.view.addConstraints([
                NSLayoutConstraint(item: profileInformationVC.view, attribute: .width, relatedBy: .equal,
                                   toItem: self.stackView, attribute: .width, multiplier: 1.0, constant: 0.0),
                profileInformationHeightConstraint
                ])
            profileInformationVC.setHeightConstraint(constraint: profileInformationHeightConstraint)
        } else {
            print("Profile Ino VC Failed to initialize")
        }

    }

    func addDoDontVC() {
        if let profileDoDontVC = ProfileDoDontViewController.instantiate(doStrings: [self.profileData.doList.first!], dontStrings: [self.profileData.dontList.first!]) {
            self.addChild(profileDoDontVC)
            self.stackView.addArrangedSubview(profileDoDontVC.view)
            profileDoDontVC.didMove(toParent: self)
            profileDoDontVC.view.translatesAutoresizingMaskIntoConstraints = false
            let profileDoDontHeightConstraint =
                NSLayoutConstraint(item: profileDoDontVC.view, attribute: .height, relatedBy: .equal,
                                   toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40)
            self.view.addConstraints([
                NSLayoutConstraint(item: profileDoDontVC.view, attribute: .width, relatedBy: .equal,
                                   toItem: self.stackView, attribute: .width, multiplier: 1.0, constant: 0.0),
                profileDoDontHeightConstraint
                ])
            profileDoDontVC.setHeightConstraint(constraint: profileDoDontHeightConstraint)
        } else {
            print("Do Dont VC failed to initialize")
        }

    }

    func addSeperator() {
        let seperatorView = UIView()
        seperatorView.translatesAutoresizingMaskIntoConstraints = false
        seperatorView.backgroundColor = self.seperatorViewColor
        self.stackView.addArrangedSubview(seperatorView)
        self.view.addConstraints([
            NSLayoutConstraint(item: seperatorView, attribute: .width, relatedBy: .equal,
                               toItem: self.stackView, attribute: .width, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: seperatorView, attribute: .height, relatedBy: .equal,
                               toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 1.0)
            ])
    }

}
