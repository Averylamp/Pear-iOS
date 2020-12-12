//
//  DetachedProfileApprovalViewController.swift
//  Pear
//
//  Created by Avery Lamp on 3/12/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class ApproveDetachedProfileViewController: UIViewController {
  
  @IBOutlet weak var scrollView: UIScrollView!
  
  @IBOutlet weak var titleLabel: UILabel!
  var detachedProfile: PearDetachedProfile!
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(detachedProfile: PearDetachedProfile) -> ApproveDetachedProfileViewController? {
    let storyboard = UIStoryboard(name: String(describing: ApproveDetachedProfileViewController.self), bundle: nil)
    guard let doDontVC = storyboard.instantiateInitialViewController() as? ApproveDetachedProfileViewController else { return nil }
    doDontVC.detachedProfile = detachedProfile
    return doDontVC
  }
  
  @objc func skipButtonClicked(sender: UIButton) {
    self.dismiss(animated: true, completion: nil)
  }
  
  @objc func saveButtonClicked(sender: UIButton) {
    if let currentUserID = DataStore.shared.currentPearUser?.documentID {
      PearProfileAPI.shared.attachDetachedProfile(user_id: currentUserID,
                                                  detachedProfile_id: detachedProfile.documentID,
                                                  creatorUser_id: detachedProfile.creatorUserID) { (result) in
        DispatchQueue.main.async {
          
          switch result {
          case .success(let success):
            print("Successfully attached detached profile: \(success)")
            if success {
              self.dismiss(animated: true, completion: nil)
            } else {
              self.alert(title: "Failed to Accept", message: "Unfortunately there was a problem with our servers.  Try again later")
            }
          case .failure(let error):
            print("Failed to attach detached profile: \(error)")
          }
        }
        
      }
    }
  }
  
}

// MARK: - Life Cycle
extension ApproveDetachedProfileViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.addFullStackVC()
    self.stylize()
  }
  
  func addFullStackVC() {
    guard let fullProfileStackVC = FullProfileStackViewController
      .instantiate(userFullProfileData: FullProfileDisplayData(pdp: self.detachedProfile)) else {
        print("Failed to create full profiles stack VC")
        return
    }
    
    self.addChild(fullProfileStackVC)
    self.scrollView.addSubview(fullProfileStackVC.view)
    fullProfileStackVC.view.translatesAutoresizingMaskIntoConstraints = false
    
    let continueContainerView = UIView()
    continueContainerView.translatesAutoresizingMaskIntoConstraints = false
    
    let continueButton = UIButton()
    continueButton.addTarget(self, action: #selector(ApproveDetachedProfileViewController.saveButtonClicked(sender:)), for: .touchUpInside)
    continueButton.stylizeDark()
    continueButton.layer.cornerRadius = 25
    continueButton.setTitle("Save & Share", for: .normal)
    continueButton.translatesAutoresizingMaskIntoConstraints = false
    continueContainerView.addSubview(continueButton)
    continueContainerView.addConstraints([
      NSLayoutConstraint(item: continueButton, attribute: .left, relatedBy: .equal,
                         toItem: continueContainerView, attribute: .left, multiplier: 1.0, constant: 20.0),
      NSLayoutConstraint(item: continueButton, attribute: .right, relatedBy: .equal,
                         toItem: continueContainerView, attribute: .right, multiplier: 1.0, constant: -20.0),
      NSLayoutConstraint(item: continueButton, attribute: .top, relatedBy: .equal,
                         toItem: continueContainerView, attribute: .top, multiplier: 1.0, constant: 10.0),
      NSLayoutConstraint(item: continueButton, attribute: .height, relatedBy: .equal,
                         toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 50)
      ])
    
    let continueSubtext = UILabel()
    continueSubtext.stylizeTextFieldTitle()
    continueSubtext.numberOfLines = 0
    continueSubtext.textAlignment = .center
    continueSubtext.text = "This will make your profile visible to other users on Pear."
    continueSubtext.translatesAutoresizingMaskIntoConstraints = false
    continueContainerView.addSubview(continueSubtext)
    continueContainerView.addConstraints([
      NSLayoutConstraint(item: continueSubtext, attribute: .left, relatedBy: .equal,
                         toItem: continueContainerView, attribute: .left, multiplier: 1.0, constant: 20.0),
      NSLayoutConstraint(item: continueSubtext, attribute: .right, relatedBy: .equal,
                         toItem: continueContainerView, attribute: .right, multiplier: 1.0, constant: -20.0),
      NSLayoutConstraint(item: continueSubtext, attribute: .top, relatedBy: .equal,
                         toItem: continueButton, attribute: .bottom, multiplier: 1.0, constant: 10.0)
      ])
    
    let skipButton = UIButton()
    skipButton.addTarget(self,
                         action: #selector(ApproveDetachedProfileViewController.skipButtonClicked(sender:)), for: .touchUpInside)
    skipButton.stylizeSubtle()
    skipButton.setTitle("Skip adding profile", for: .normal)
    skipButton.translatesAutoresizingMaskIntoConstraints = false
    continueContainerView.addSubview(skipButton)
    continueContainerView.addConstraints([
      NSLayoutConstraint(item: skipButton, attribute: .left, relatedBy: .equal,
                         toItem: continueContainerView, attribute: .left, multiplier: 1.0, constant: 20.0),
      NSLayoutConstraint(item: skipButton, attribute: .right, relatedBy: .equal,
                         toItem: continueContainerView, attribute: .right, multiplier: 1.0, constant: -20.0),
      NSLayoutConstraint(item: skipButton, attribute: .top, relatedBy: .equal,
                         toItem: continueSubtext, attribute: .bottom, multiplier: 1.0, constant: 10.0),
      NSLayoutConstraint(item: skipButton, attribute: .bottom, relatedBy: .equal,
                         toItem: continueContainerView, attribute: .bottom, multiplier: 1.0, constant: -10.0)
      ])
    
    fullProfileStackVC.stackView.addArrangedSubview(continueContainerView)
    
    self.scrollView.addConstraints([
      NSLayoutConstraint(item: fullProfileStackVC.view!, attribute: .centerX, relatedBy: .equal,
                         toItem: self.scrollView, attribute: .centerX, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: fullProfileStackVC.view!, attribute: .width, relatedBy: .equal,
                         toItem: self.scrollView, attribute: .width, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: fullProfileStackVC.view!, attribute: .top, relatedBy: .equal,
                         toItem: self.scrollView, attribute: .top, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: fullProfileStackVC.view!, attribute: .bottom, relatedBy: .equal,
                         toItem: self.scrollView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
      ])
    fullProfileStackVC.didMove(toParent: self)
    
  }
  
  func stylize() {
    self.titleLabel.stylizeTitleLabel()
    self.titleLabel.text = "\(detachedProfile.creatorFirstName!) Created a Profile for You!"
    
  }
  
}
