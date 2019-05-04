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
    guard let friendFullProfileVC = R.storyboard.friendFullProfileViewController()
      .instantiateInitialViewController() as? FriendFullProfileViewController else {
        return nil
    }
    friendFullProfileVC.fullProfileData = fullProfileData
    return friendFullProfileVC
  }
  
  @IBAction func backButtonClicked(_ sender: Any) {
    self.navigationController?.popViewController(animated: true)
  }
  
  @IBAction func editProfileButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    var editProfileObject: UpdateProfileData?
    if let detachedProfile = fullProfileData.originObject as? PearDetachedProfile {
      do {
        editProfileObject = try UpdateProfileData(detachedProfile: detachedProfile)
      } catch {
        print("Unable to create Update Profile Data Object")
      }
    } else if let pearUser = fullProfileData.originObject as? PearUser {
      do {
        editProfileObject = try UpdateProfileData(pearUser: pearUser)
      } catch {
        print("Unable to create Update Profile Data Object")
      }
    }
    guard let editProfileData = editProfileObject else {
      print("Failed update profile data creation")
      return
    }
    guard let editFriendProfileVC = FriendEditProfileViewController.instantiate(updateProfileData: editProfileData,
                                                                                firstName: self.fullProfileData.firstName ?? "") else {
                                                                                  print("Failed to create edit friend profile VC")
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
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.navigationController?.interactivePopGestureRecognizer?.delegate = self
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

extension FriendFullProfileViewController: UIGestureRecognizerDelegate {
  
  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
  
}
