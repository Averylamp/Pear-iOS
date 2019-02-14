//
//  FullProfileViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/13/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit

class FullProfileViewController: UIViewController {
    
    var profileData: ProfileData!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    
    let seperatorViewColor: UIColor = UIColor(white: 0.2, alpha: 0.1)
    
    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate(profileData: ProfileData) -> FullProfileViewController {
        let storyboard = UIStoryboard(name: String(describing: FullProfileViewController.self), bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! FullProfileViewController
        vc.profileData = profileData
        return vc
    }
    
    
}

// MARK: - Life Cycle
extension FullProfileViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addProfileImageVC()
        self.addSeperator()
        self.addInformationVC()
        self.addSeperator()
        self.addTitle(text: "ABOUT")
        self.addBioVC()
        self.addSeperator()
        self.addTitle(text: "DO'S & DONT's")
        self.addDoDontVC()
        self.addSeperator()
    }
    
    func addSimpleCloseButton(closeAction: @escaping ()->Void){
        let closeButton = UIButton(frame: CGRect(x: 20, y: 50, width: 36, height: 36))
        closeButton.setImage(UIImage(named: "onboarding-close-button"), for: .normal)
        self.view.addSubview(closeButton)
        closeButton.addTargetClosure { (sender) in
            closeAction()
        }
        
    }
    
    func addButtonToStack(buttonTitle: String, buttonAction: ()->Void, buttonInsets: UIEdgeInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16), sectionHeight: CGFloat = 60){
        self.addSeperator()
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = true
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = true
        button.backgroundColor = UIColor(red:0.00, green:0.90, blue:0.62, alpha:1.00)
        button.setTitleColor(UIColor.black, for: .normal)
        button.layer.cornerRadius = 8
        button.layer.shadowOffset = CGSize(width: 1, height: 1)
        button.layer.shadowOpacity = 0.2
        button.layer.shadowRadius = 3
        button.layer.shadowColor = UIColor.black.cgColor
        button.setTitle(buttonTitle, for: .normal)
        containerView.addSubview(button)
        self.stackView.addSubview(containerView)
        self.view.addConstraints([
                NSLayoutConstraint(item: button, attribute: .left, relatedBy: .equal, toItem: containerView, attribute: .left, multiplier: 1.0, constant: buttonInsets.left),
                NSLayoutConstraint(item: button, attribute: .right, relatedBy: .equal, toItem: containerView, attribute: .right, multiplier: 1.0, constant: -buttonInsets.right),
                NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: containerView, attribute: .top, multiplier: 1.0, constant: buttonInsets.top),
                NSLayoutConstraint(item: button, attribute: .bottom, relatedBy: .equal, toItem: containerView, attribute: .bottom, multiplier: 1.0, constant: -buttonInsets.bottom),
                NSLayoutConstraint(item: containerView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: sectionHeight),
                NSLayoutConstraint(item: containerView, attribute: .width, relatedBy: .equal, toItem: self.stackView, attribute: .width, multiplier: 1.0, constant: 0),
                NSLayoutConstraint(item: containerView, attribute: .centerX, relatedBy: .equal, toItem: self.stackView, attribute: .centerX, multiplier: 1.0, constant: 0),
            ])
        
    }
    
    func addProfileImageVC(){
        let profileImageVC = ProfileImageViewController.instantiate(images: self.profileData.images)
        self.addChild(profileImageVC)
        self.stackView.addArrangedSubview(profileImageVC.view)
        profileImageVC.didMove(toParent: self)
        profileImageVC.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraints([
            NSLayoutConstraint(item: profileImageVC.view, attribute: .width, relatedBy: .equal, toItem: self.stackView, attribute: .width, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: profileImageVC.view, attribute: .height, relatedBy: .equal, toItem: self.stackView, attribute: .width, multiplier: 1.0, constant: 0.0)])
        
        self.view.layoutIfNeeded()
    }
    
    func addInformationVC(){
        var endorsedName = self.profileData.endorsedFirstName!
        if let endorsedLastName = self.profileData.endorsedLastName{
            endorsedName = endorsedName + " " + String(endorsedLastName.prefix(1)) + "."
        }
        
        let profileInformationVC = ProfileInformationViewController.instantiate(firstName: self.profileData.firstName,
                                                                                age: self.profileData.age,
                                                                                endorsedName: endorsedName,
                                                                                locationData: self.profileData.locationData,
                                                                                schoolName: self.profileData.schoolName,
                                                                                workData: self.profileData.work)
        self.addChild(profileInformationVC)
        self.stackView.addArrangedSubview(profileInformationVC.view)
        profileInformationVC.didMove(toParent:  self)
        profileInformationVC.view.translatesAutoresizingMaskIntoConstraints = false
        let profileInformationHeightConstraint = NSLayoutConstraint(item: profileInformationVC.view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40)
        self.view.addConstraints([
                NSLayoutConstraint(item: profileInformationVC.view, attribute: .width, relatedBy: .equal, toItem: self.stackView, attribute: .width, multiplier: 1.0, constant: 0.0),
                profileInformationHeightConstraint
            ])
        profileInformationVC.setHeightConstraint(constraint: profileInformationHeightConstraint)
        
    }
    
    func addBioVC(){
        let profileInformationVC = ProfileAboutViewController.instantiate(aboutBio: self.profileData.shortBio)
        self.addChild(profileInformationVC)
        self.stackView.addArrangedSubview(profileInformationVC.view)
        profileInformationVC.didMove(toParent:  self)
        profileInformationVC.view.translatesAutoresizingMaskIntoConstraints = false
        let profileShortBioHeightConstraint = NSLayoutConstraint(item: profileInformationVC.view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40)
        self.view.addConstraints([
            NSLayoutConstraint(item: profileInformationVC.view, attribute: .width, relatedBy: .equal, toItem: self.stackView, attribute: .width, multiplier: 1.0, constant: 0.0),
            profileShortBioHeightConstraint
            ])
        profileInformationVC.setHeightConstraint(constraint: profileShortBioHeightConstraint)
        
    }
    
    func addDoDontVC(){
        let profileDoDontVC = ProfileDoDontViewController.instantiate(doStrings: self.profileData.doList, dontStrings: self.profileData.dontList)
        self.addChild(profileDoDontVC)
        self.stackView.addArrangedSubview(profileDoDontVC.view)
        profileDoDontVC.didMove(toParent:  self)
        profileDoDontVC.view.translatesAutoresizingMaskIntoConstraints = false
        let profileDoDontHeightConstraint = NSLayoutConstraint(item: profileDoDontVC.view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40)
        self.view.addConstraints([
            NSLayoutConstraint(item: profileDoDontVC.view, attribute: .width, relatedBy: .equal, toItem: self.stackView, attribute: .width, multiplier: 1.0, constant: 0.0),
            profileDoDontHeightConstraint
            ])
        profileDoDontVC.setHeightConstraint(constraint: profileDoDontHeightConstraint)
        
    }
    
    func addSeperator(){
        let seperatorView = UIView()
        seperatorView.translatesAutoresizingMaskIntoConstraints = false
        seperatorView.backgroundColor = self.seperatorViewColor
        self.stackView.addArrangedSubview(seperatorView)
        self.view.addConstraints([
                NSLayoutConstraint(item: seperatorView, attribute: .width, relatedBy: .equal, toItem: self.stackView, attribute: .width, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: seperatorView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 1.0)
            ])
    }
    
    func addTitle(text: String){
        let titleView = UIView()
        titleView.translatesAutoresizingMaskIntoConstraints = false
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(titleLabel)
        titleLabel.text = text
        titleLabel.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        titleLabel.textColor = UIColor(red:0.60, green:0.60, blue:0.60, alpha:1.00)
        self.stackView.addArrangedSubview(titleView)
        self.view.addConstraints([
            NSLayoutConstraint(item: titleView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 30),
            NSLayoutConstraint(item: titleView, attribute: .width, relatedBy: .equal, toItem: self.stackView, attribute: .width, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: titleView, attribute: .centerX, relatedBy: .equal, toItem: self.stackView, attribute: .centerX, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: titleLabel, attribute: .left, relatedBy: .equal, toItem: titleView, attribute: .left, multiplier: 1.0, constant: 30),
            NSLayoutConstraint(item: titleLabel, attribute: .right, relatedBy: .equal, toItem: titleView, attribute: .right, multiplier: 1.0, constant: -30),
            NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: titleView, attribute: .top, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: titleLabel, attribute: .bottom, relatedBy: .equal, toItem: titleView, attribute: .bottom, multiplier: 1.0, constant: 0),
            ])
        
    }
    
}
