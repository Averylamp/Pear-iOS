//
//  FullProfileScrollViewController.swift
//  Pear
//
//  Created by Avery Lamp on 3/12/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class FriendFullProfileViewController: UIViewController {

  var fullProfileData: FullProfileDisplayData!
  
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var editButton: UIButton!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(fullProfileData: FullProfileDisplayData!) -> FriendFullProfileViewController? {
    let storyboard = UIStoryboard(name: String(describing: FriendFullProfileViewController.self), bundle: nil)
    guard let doDontVC = storyboard.instantiateInitialViewController() as? FriendFullProfileViewController else { return nil }
    doDontVC.fullProfileData = fullProfileData
    return doDontVC
  }
  
  @IBAction func backButtonClicked(_ sender: Any) {
    self.navigationController?.popViewController(animated: true)
  }
  
  @IBAction func editProfileButtonClicked(_ sender: Any) {
    tg
    let detachedProfile = fullProfileData.originObject as? PearDetachedProfile
    var userProfile: PearUserProfile?
    guard let userID = DataStore.shared.currentPearUser?.documentID else {
      print("Failed to get current user")
      return
    }
    
    if let matchingUser = fullProfileData.originObject as? MatchingPearUser {
      for matchingUserProfile in matchingUser.userProfiles where matchingUserProfile.creatorUserID == userID {
        userProfile = matchingUserProfile
        break
      }
    }
    
    guard let editFriendProfileVC = FriendEditProfileViewController.instantiate(detachedProfile: detachedProfile,
                                                                                userProfile: userProfile,
                                                                                firstName: fullProfileData.firstName) else {
                                                                                  print("Failed to create edit friend VC")
                                                                                  return
    }
    self.navigationController?.pushViewController(editFriendProfileVC, animated: true)
  }
  
}

// MARK: - Life Cycle
extension FriendFullProfileViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
    self.addFullStackVC()
  }
  
  func stylize() {
    self.editButton.layer.cornerRadius = 30
    self.editButton.layer.shadowOpacity = 0.2
    self.editButton.layer.shadowColor = UIColor.black.cgColor
    self.editButton.layer.shadowRadius = 6
    self.editButton.layer.shadowOffset = CGSize(width: 2, height: 2)
  }
  
  func addFullStackVC() {
    guard let fullProfileStackVC = FullProfileStackViewController.instantiate(userFullProfileData: self.fullProfileData) else {
        print("Failed to create full profiles stack VC")
        return
    }
    
    self.addChild(fullProfileStackVC)
    self.scrollView.addSubview(fullProfileStackVC.view)
    fullProfileStackVC.view.translatesAutoresizingMaskIntoConstraints = false
    
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
}
