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
        let profileInformationVC = ProfileInformationViewController.instantiate(firstName: self.profileData.firstName,
                                                                                age: self.profileData.age,
                                                                                endorsedName: self.profileData.endorsedName,
                                                                                locationData: self.profileData.locationData,
                                                                                schoolName: self.profileData.schoolName,
                                                                                workData: self.profileData.work)
        self.addChild(profileInformationVC)
        self.stackView.addArrangedSubview(profileInformationVC.view)
        profileInformationVC.didMove(toParent:  self)
        profileInformationVC.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraints([
                NSLayoutConstraint(item: profileInformationVC.view, attribute: .width, relatedBy: .equal, toItem: self.stackView, attribute: .width, multiplier: 1.0, constant: 0.0)
            ])
        
        self.view.layoutIfNeeded()
        
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
    
}
